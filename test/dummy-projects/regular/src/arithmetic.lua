local M = {}

function M.add(x, y)
  if y == 0 then
    return x
  end
  return M.add(x + 1, y - 1)
end

function M.multiply(x, y)
  if y == 0 then
    return 0
  end
  if y == 1 then
    return x
  end
  return M.add(x + x, y - 1)
end

return M
