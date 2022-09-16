
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
  # default_action {
  #   type = "redirect"
   
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
       
  #   }
  # }
#}














# resource "aws_lb_listener_rule" "static" {
#   listener_arn = aws_lb_listener.alb_listener.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/static/*"]
#     }
#   }

#   condition {
#     host_header {
#       values = ["example.com"]
#     }
#   }
# }


#   default_action {
#     target_group_arn = aws_lb_target_group.target_group.arn
#     type             = "redirect"
#   }
# }
#  default_action {
  #   type = "redirect"

  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }
  # # default_action {
  # #   type = "fixed-response"

  # #   fixed_response {
  # #     content_type = "text/plain"
  #     message_body = "Fixed response content"
  #     status_code  = "200"
  #   }
  # }

















  

# resource "aws_lb_listener" "alb_listener" {
    

#   load_balancer_arn = aws_lb.alb.arn

#   protocol          = "TCP"
#   port              = 80

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_group  .arn
#   }
# }
