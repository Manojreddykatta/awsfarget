data "aws_iam_role" "iam" {

  name = "ecs2"

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
 launch_type     = "FARGATE"
 
  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }
  # ordered_placement_strategy {

  #   type  = "random"

  #   field = "cpu"

  # }

  load_balancer {
    

    target_group_arn = aws_lb_target_group.target_group  .arn

    container_name   = "mahi"

     container_port   = 80

  }

  # placement_constraints {

  #   type       = "memberOf"

  #   expression = "attribute:ecs.availability-zone in [ap-south-1a, ap-south-1b]"

  # }
#   depends_on = [
#     aws_ecs_task_definition
#   ]

}

resource "aws_ecs_task_definition" "task_definition" {
  family = "service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
   cpu       = 1024
   memory    = 2048
   execution_role_arn = data.aws_iam_role.iam.arn
    runtime_platform {
      operating_system_family = "WINDOWS_SERVER_2019_CORE"
      cpu_architecture = "X86_64"
   } 
   
  container_definitions = file("./service.json")
#     {
#       name      = "mahi"
#       image     = "061280019180.dkr.ecr.ap-south-1.amazonaws.com/mahi-ecr:latest"
#       cpu       = 1024
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     }
# ])
}


