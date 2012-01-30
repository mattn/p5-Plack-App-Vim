scriptencoding utf-8

let s:comments = get(s:, 'comments', [])

function! vimplack#handle(req)
  let req = json#decode(a:req)
  if req.uri == "/"
    let res = [200, ["Content-Type", "text/html; charset=utf-8"], [""
\."<html>"
\."<title>comment board</title>"
\."<body>"
\."<form action='/regist' method='post'>"
\."コメント:<input type='text' name='comment' value='' /><br />"
\."<input type='submit' value='登録' />"
\."</form>"
\.join(map(copy(s:comments), 'html#encodeEntityReference(v:val)'), '<br />')
\."</body>"
\."</html>"
\]]
  elseif req.uri == '/regist' && req.method == 'POST'
    let params = {}
    for _ in map(split(req.content, '&'), 'split(v:val,"=")')
      let params[_[0]] = iconv(http#decodeURI(_[1]), 'utf-8', &encoding)
    endfor
	if has_key(params, 'comment')
      call add(s:comments, params['comment'])
    endif
    let res = [302, ["Location", "/"], [""]]
  else
    let res = [404, [], ["404 Dan Not Found"]]
  endif
  return json#encode(res)
endfunction
