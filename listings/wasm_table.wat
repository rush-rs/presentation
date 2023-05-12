(func $fib
  (param $n i64)
  (result i64)
  ;; ...
)

;; ...
if (result i64)
  local.get $n
else
  ;; ...
end

loop
  ;; ...
  br 0
end
