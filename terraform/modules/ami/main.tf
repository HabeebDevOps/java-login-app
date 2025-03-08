# AMI Module - Launch an EC2 Instance and Create AMI

resource "aws_instance" "base_instance" {
  ami           = "ami-091f18e98bc129c4e" # Change if needed
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    aws --version
    sudo yum install -y amazon-cloudwatch-agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
    sudo yum install -y amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
    sudo systemctl enable amazon-ssm-agent
  EOF

  tags = {
    Name = var.instance_name
  }

  lifecycle {
    create_before_destroy = true  # Create a new resource before destroying the old one
    prevent_destroy       = false  # Allow the instance to be destroyed
  }
}

resource "aws_ami_from_instance" "global_ami" {
  name               = var.ami_name
  source_instance_id = aws_instance.base_instance.id
  depends_on         = [aws_instance.base_instance]
}
 
# Launch an EC2 Instance from Global AMI to Install Nginx
resource "aws_instance" "nginx_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras enable nginx1
    sudo yum install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    while true; do
      memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
      aws cloudwatch put-metric-data --metric-name MemoryUsage --namespace Custom --value $memory_usage --dimensions InstanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
      sleep 60
    done &
  EOF

  tags = {
    Name = "NginxInstance"
  }

  lifecycle {
    create_before_destroy = true  # Create a new resource before destroying the old one
    prevent_destroy       = false  # Allow the instance to be destroyed
  }
}

# Create a Golden AMI for Nginx
resource "aws_ami_from_instance" "nginx_ami" {
  name               = var.nginx_ami_name
  source_instance_id = aws_instance.nginx_instance.id
  depends_on         = [aws_instance.nginx_instance]
}

# Launch an EC2 Instance from Global AMI to Install Tomcat
resource "aws_instance" "tomcat_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y java-11-openjdk-devel
    wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.53/bin/apache-tomcat-9.0.53.tar.gz
    sudo tar -xvzf apache-tomcat-9.0.53.tar.gz -C /opt/
    sudo ln -s /opt/apache-tomcat-9.0.53 /opt/tomcat
    sudo sh /opt/tomcat/bin/startup.sh
    sudo bash -c 'cat <<EOT > /etc/systemd/system/tomcat.service
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=network.target

    [Service]
    Type=forking
    Environment=JAVA_HOME=/usr/lib/jvm/jre
    Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
    Environment=CATALINA_HOME=/opt/tomcat
    Environment=CATALINA_BASE=/opt/tomcat
    Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
    ExecStart=/opt/tomcat/bin/startup.sh
    ExecStop=/opt/tomcat/bin/shutdown.sh
    User=tomcat
    Group=tomcat
    UMask=0007
    RestartSec=10
    Restart=always
    [Install]
    WantedBy=multi-user.target
    EOT'
    sudo systemctl daemon-reload
    sudo systemctl start tomcat
    sudo systemctl enable tomcat
  EOF

  tags = {
    Name = "TomcatInstance"
  }

  lifecycle {
    create_before_destroy = true  # Create a new resource before destroying the old one
    prevent_destroy       = false  # Allow the instance to be destroyed
  }
}

# Create a Golden AMI for Tomcat
resource "aws_ami_from_instance" "tomcat_ami" {
  name               = var.tomcat_ami_name
  source_instance_id = aws_instance.tomcat_instance.id
  depends_on         = [aws_instance.tomcat_instance]
}

# Launch an EC2 Instance from Global AMI to Maven Nginx
resource "aws_instance" "maven_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = var.instance_type

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y git java-11-openjdk-devel
    wget https://mirrors.ocf.berkeley.edu/apache/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
    sudo tar -xvzf apache-maven-3.8.4-bin.tar.gz -C /opt/
    sudo ln -s /opt/apache-maven-3.8.4 /opt/maven
    echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile.d/maven.sh
    echo "export PATH=\$M2_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh
    mvn -version
  EOF

  tags = {
    Name = "MavenInstance"
  }

  lifecycle {
    create_before_destroy = true  # Create a new resource before destroying the old one
    prevent_destroy       = false  # Allow the instance to be destroyed
  }
}

# Create a Golden AMI for Maven
resource "aws_ami_from_instance" "maven_ami" {
  name               = var.maven_ami_name
  source_instance_id = aws_instance.maven_instance.id
  depends_on         = [aws_instance.maven_instance]
}