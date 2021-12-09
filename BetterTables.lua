local TableTypes = {
  Empty=0,
  Array=1,
  Dictionary=2,
  Mixed=3
}

local BetterTables = {
  __index = function(t, index)
    return t:GetTable()[index]
  end,
  __newindex = function(t, index, value)
    t:GetTable()[index] = value
    if value == nil then
      rawset(t, "_type", getTableType(t:GetTable()))
      rawset(t, "_length", t:GetLength()-1)
    elseif t:GetType() == TableTypes.Empty then
      if typeof(index) == "number" then
        rawset(t, "_type", TableTypes.Array)
      else
        rawset(t, "_type", TableTypes.Dictionary)
      end
      rawset(t, "_length", t:GetLength()+1)
    elseif t:GetType() == TableTypes.Array then
      if typeof(index) == "string" then
        rawset(t, "_type", TableTypes.Mixed)
      end
      rawset(t, "_length", t:GetLength()+1)
    elseif t:GetType() == TableTypes.Dictionary then
      if typeof(index) == "number" then
        rawset(t, "_type", TableTypes.Mixed)
      end
      rawset(t, "_length", t:GetLength()+1)
    end
  end,
}

--[[
  Modified.
  Source: https://devforum.roblox.com/t/detecting-type-of-table-empty-array-dictionary-mixedtable/292323/15
  @XAXA
]]
function getTableType(t)
  if next(t) == nil then return TableTypes.Empty end
  local isArray = true
  local isDictionary = true
  for k, _ in next, t do
    if typeof(k) == "number" and k%1 == 0 and k > 0 then
      isDictionary = false
    else
      isArray = false
    end
    if isDictionary == false and isArray == false then
      break
    end
  end
  if isArray then
    return TableTypes.Array
  elseif isDictionary then
    return TableTypes.Dictionary
  else
    return TableTypes.Mixed
  end
end

--[[
  Source: http://lua-users.org/wiki/CopyTable
]]
function deepCopy(orig, copies)
  copies = copies or {}
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    if copies[orig] then
      copy = copies[orig]
    else
      copy = {}
      copies[orig] = copy
      for orig_key, orig_value in next, orig, nil do
        copy[deepCopy(orig_key, copies)] = deepCopy(orig_value, copies)
      end
      setmetatable(copy, deepCopy(getmetatable(orig), copies))
    end
  else
    copy = orig
  end
  return copy
end

function BetterTables.new(...)
  local args = table.pack(...)
  local newTable = {}
  if args[1] and typeof(args[1]) == "table" then 
    if rawget(args[1], "_isBetterTable") then
      newTable = args[1]:DeepCopy()
    else
      newTable = deepCopy(args[1])
    end
  elseif typeof(args[1]) == "number" then
    if args[2] then
      newTable = table.create(args[1], args[2])
    else
      newTable = table.create(args[1])
    end
  end

  local findIndexFunction = function(t, predicate)
    if typeof(predicate) == "function" then
      for k, v in t:GetIterator() do
        if predicate(v, k, t) then
          return k
        end
      end
    else
      for k, v in t:GetIterator() do
        if v == predicate then
          return k
        end
      end
    end
    return nil
  end
  local Table = setmetatable(
    {
      --- Returns the actual table this BetterTable represents.
      -- @return The table.
      GetTable = function(t)
        return rawget(t, "_table")
      end,

      --- Returns the table type of the represented table.
      -- @return The table type.
      GetType = function(t)
        return rawget(t, "_type")
      end,

      --- Returns the table length of the represented table.
      -- @return The table length.
      GetLength = function(t)
        return rawget(t, "_length")
      end,

      --- Inserts a new number-based index value into the table.
      -- @param pos The number-based position (optional).
      -- @param value The value to insert.
      Insert = function(t, ...)
        if t:GetType() == TableTypes.Empty then
          rawset(t, "_type", TableTypes.Array)
          rawset(t, "_length", t:GetLength()+1)
          table.insert(t:GetTable(), ...)
        else
          if t:GetType() == TableTypes.Dictionary then
            rawset(t, "_type", TableTypes.Mixed)
          end
          rawset(t, "_length", t:GetLength()+1)
          table.insert(t:GetTable(), ...)
        end
      end,

      --- Removes a number-based index from the table.
      -- @param pos The number-based position.
      Remove = function(t, pos)
        table.remove(t:GetTable(), pos)
        rawset(t, "_length", t:GetLength()-1)
        if t:GetType() == TableTypes.Array and t:GetLength() == 0 then
          rawset(t, "_type", TableTypes.Empty)
        elseif t:GetType() == TableTypes.Mixed then
          rawset(t, "_type", getTableType(t:GetTable()))
        end
      end,

      --- Sorts the table using lua's table.sort()
      -- @param sortFunc The function used to sort the table.
      Sort = function(t, sortFunc)
        if t:GetType() ~= TableTypes.Array then
          error("Attempt to use Sort on a non-array table")
        end
        table.sort(t:GetTable(), sortFunc)
      end,

      --- Gets the iterator needed to properly iterate over this table
      -- @return The iterator.
      GetIterator = function(t)
        if t:GetType() == TableTypes.Empty then
          return pairs({})
        elseif t:GetType() == TableTypes.Array then
          return ipairs(t:GetTable())
        else
          return pairs(t:GetTable())
        end
      end,

      --- Returns the first value in the table to pass the predicate function, or nil if none pass.
      -- @param predicate A function which is passed the current iteration's value, key, and the table itself and returns true or false.
      Find = function(t, predicate)
        for k, v in t:GetIterator() do
          if predicate(v, k, t) then
            return v
          end
        end
        return nil
      end,

      --- Returns the key (or index) of the first value in the table to pass the predicate function or are equal to the value passed.
      -- @param predicate When passed as a function, it is passed the current iteration's value, key, and the table itself and returns true or false. When passed as any other variant, a simple equivalency check will be done.
      FindIndex = findIndexFunction,
      FindKey = findIndexFunction,

      --- Deeply copies the underlying table and returns it as a regular table.
      -- @return The new deep cloned table.
      DeepCopy = function(t)
        return deepCopy(t:GetTable())
      end,

      --- Shallowly copies the underlying table and returns it as a regular table.
      -- @return The new shallowly cloned table.
      ShallowCopy = function(t)
        -- Source: http://lua-users.org/wiki/CopyTable
        local orig_type = type(t:GetTable())
        local copy
        if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in pairs(t:GetTable()) do
            copy[orig_key] = orig_value
          end
        else
          copy = t:GetTable()
        end
        return copy
      end,

      --- Changes all values to the passed value in the range provided.
      -- @param value The value to change to.
      -- @param from The low-end index (optional, default 0).
      -- @param to The high-end index.
      Fill = function(t, value, from, to)
        if to == nil then
          to = from
          from = 0
        end
        for i = from, to do
          t[i] = value
        end
      end,

      --- Checks whether every value in the table passes the predicate function.
      -- @param predicate A function which is passed the current iteration's value, key, and the table itself and returns true or false.
      -- @return A boolean value which is true if every value passes the function passed, false otherwise.
      Every = function(t, predicate)
        for k, v in t:GetIterator() do
          if not predicate(v, k, t) then
            return false
          end
        end
        return true
      end,

      --- Checks whether any of the values in the table passes the predicate function.
      -- @param predicate A function which is passed the current iteration's value, key, and the table itself and returns true or false.
      -- @return A boolean value which is true if any value passes the function passed, false otherwise.
      Some = function(t, predicate)
        for k, v in t:GetIterator() do
          if predicate(v, k, t) then
            return true
          end
        end
        return false
      end,

      --- Removes all values from the table which do not pass the filter function
      -- @param filter A function which is passed the current iteration's value, key, and the table itself and returns true or false.
      Filter = function(t, filter)
        if t:GetType() == TableTypes.Array then
          for i = t:GetLength(), 1, -1 do
            if not filter(t[i], i, t) then
              t:Remove(i)
            end
          end
        else
          for k, v in t:GetIterator() do
            if not filter(v, k, t) then
              t[k] = nil
            end
          end
        end
      end,

      --- Concatenates two tables together.
      -- If both tables are array-like, then the values will be added to the end of the first table.
      -- If either table is a dictionary, or mixed, then values will be overridden by the new table if they conflict.
      -- @param tOther The other table. Can be a BetterTable, or a regular table.
      Concat = function(t, tOther)
        if rawget(tOther, "_isBetterTable") then
          if (t:GetType() == TableTypes.Empty or t:GetType() == TableTypes.Array) and (rawget(tOther, "_type") == TableTypes.Empty or rawget(tOther, "_type") == TableTypes.Array) then
            for k, v in tOther:GetIterator() do
              t:Insert(v)
            end
          else
            for k, v in tOther:GetIterator() do
              t[k] = v
            end
          end
        else
          if (t:GetType() == TableTypes.Empty or t:GetType() == TableTypes.Array) and (getTableType(tOther) == TableTypes.Empty or getTableType(tOther) == TableTypes.Array) then
            for k, v in ipairs(tOther) do
              t:Insert(v)
            end
          else
            for k, v in pairs(tOther) do
              t[k] = v
            end
          end
        end
      end,

      Shuffle = function(t)
        if t:GetType() ~= TableTypes.Array then
          error("Attempt to shuffle non-array table")
        end
        local len = t:GetLength()
        for i = 1, len do
          local temp = t[i]
          local newIndex = math.random(1, len)
          t[i] = t[newIndex]
          t[newIndex] = temp
        end
      end,

      _table = newTable,
      _type = if newTable then getTableType(newTable) else TableTypes.Empty,
      _length = if newTable then #newTable else 0,
      _isBetterTable = true
    }, BetterTables)
  return Table
end

return BetterTables
