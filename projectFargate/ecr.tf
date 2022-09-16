data "aws_iam_role" "iam" {

  name = "AWSServiceRoleForECS"

}
resource "aws_ecr_repository" "aws_ecr" {
  name                 = "mahi-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
 }
  
  tags = {
   name = "ecr"
 }
 }
 
 resource "aws_ecs_cluster" "cluster" {

  name = "mahiFargateCluster"



  setting {

    name  = "containerInsights"

    value = "enabled"

  }

}

resource "aws_ecs_service" "ecs" {
     

  name            = "mahiFargate-ecs"

  cluster         = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.task_definition.arn

  desired_count   = 3

  iam_role        = data.aws_iam_role.iam.arn
  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }
  ordered_placement_strategy {

    type  = "binpack"

    field = "cpu"

  }

  load_balancer {
    

    target_group_arn = aws_lb_target_group.target_group  .arn

    container_name   = "mahi"

     container_port   = 80

  }

  placement_constraints {

    type       = "memberOf"

    expression = "attribute:ecs.availability-zone in [ap-south-1a, ap-south-1b]"

  }
#   depends_on = [
#     aws_ecs_task_definition
#   ]

}



# resource "aws_ecs_cluster_capacity_providers" "example" {

#   cluster_name = aws_ecs_cluster.cluster.name



#   capacity_providers = [aws_ecs_capacity_provider.example.name]



#   default_capacity_provider_strategy {

#     base              = 1

#     weight            = 100

#     capacity_provider = aws_ecs_capacity_provider.example.name

#   }

# }


# resource "aws_ecs_task_definition" "task_definition" {
# family  = "mahi"
# requires_compatibilities = ["FARGATE"]
# network_mode = "awsvpc"
# cpu = 1024
# memory  = 2048
#  container_definitions = <<TASK_DEFINITION
# [
#  {
#  "name": "mahi",
#  "image": "mcr.microsoft.com/windows/servercore/iis",
#  "cpu": 1024,
#  "memory": 2048,
#  "essential": true,
#  "portMapping" : [
#     { 
#      "protocol": "tcp",
#      "container port" : 8080,
#      "host_port" : 0
#     }
#  ] 
#  }
# ]
# TASK_DEFINITION

#  runtime_platform {
#  operating_system_family = "WINDOWS_SERVER_2019_CORE"
#  cpu_architecture = "X86_64"
# }
# depends_on = [
#   aws_ecs_cluster.cluster
# ]
# }
resource "aws_ecs_task_definition" "task_definition" {
  family = "service"
  network_mode = "awsvpc"

  container_definitions = jsonencode([
    {
      name      = "mahi"
      image     = "service-mahi"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
])
}


