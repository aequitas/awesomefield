class webserver {
  Service[Nginx] -> Class[Apache]
  Host <| |> -> Class[Nginx]
  Host <| |> -> Class[Apache]
}
