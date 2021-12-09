local BetterTables = require(script.Parent)
local TableTypes = {
	Empty=0,
	Array=1,
	Dictionary=2,
	Mixed=3
}

return function()
	describe("Basic Table Functionality", function()
		it("should create an empty table", function()
			expect(BetterTables.new():GetLength()).to.equal(0)
		end)

		it("should create a table with a length of 1",function()
			expect(BetterTables.new({[1]=1}):GetLength()).to.equal(1)
		end)
		
		it("should index a dictionary properly", function()
			local t = BetterTables.new()
			t["hi"] = 20
			expect(t["hi"]).to.equal(20)
		end)
		
		it("should insert and index number-based values properly", function()
			local t = BetterTables.new()
			t:Insert("Hello")
			expect(t[1]).to.equal("Hello")
		end)
		
		it("should remove number-based values properly", function()
			local t = BetterTables.new()
			t:Insert("Hello")
			t:Remove(1)
			expect(t[1]).never.to.be.ok()
		end)
		
		it("should insert and read from mixed tables", function()
			local t = BetterTables.new()
			t:Insert("Hello")
			t["Byte"] = 8
			expect(t[1]).to.equal("Hello")
			expect(t["Byte"]).to.equal(8)
		end)
		
		it("should get the proper iterator for an array table", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert("Hello!")
			end
			local last = -1
			for i, v in t:GetIterator() do
				if i < last then
					error("i is less than last")
				end
				last = i
			end
		end)
		
		it("should get the proper iterator for a dictionary or mixed table", function()
			local t = BetterTables.new()
			local checked = {}
			for i = 1, 100 do
				t["Hello"..tostring(i)] = "hi"
				checked["Hello"..tostring(i)] = false
			end
			for k, v in t:GetIterator() do
				if checked[k] ~= nil then
					checked[k] = true
				else
					error("Unexpected key while iterating dictionary pairs: " .. k)
				end
			end
			for k, v in pairs(checked) do
				if not v then
					error("Key: " .. k .. " not checked while iterating dictionary pairs")
				end
			end
		end)
		
		it("should sort an array-like table in ascending order", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(0, 100))
			end
			t:Sort()
			local last = -1
			for i = 1, t:GetLength() do
				if t[i] < last then
					error("t[i] is less than last")
				end 
				last = t[i]
			end
		end)
		
		it("should sort an array-like table in descending order", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(0, 100))
			end
			t:Sort(function(a, b)
				return a > b
			end)
			local last = 101
			for i = 1, t:GetLength() do
				if t[i] > last then
					error("t[i] is greater than last")
				end 
				last = t[i]
			end
		end)
	end)
	
	describe("Advanced Table Functionality", function()
		it("should update an empty table to an array table", function()
			local t = BetterTables.new()
			expect(t:GetType()).to.equal(TableTypes.Empty)
			t:Insert("Hello!")
			expect(t:GetType()).to.equal(TableTypes.Array)
		end)
		
		it("should update an empty table to an dictionary table", function()
			local t = BetterTables.new()
			expect(t:GetType()).to.equal(TableTypes.Empty)
			t["Yay!"] = "Hello!"
			expect(t:GetType()).to.equal(TableTypes.Dictionary)
		end)
		
		it("should update an array table to a mixed table", function()
			local t = BetterTables.new()
			t:Insert("Hello!")
			expect(t:GetType()).to.equal(TableTypes.Array)
			t["Yay!"] = "Hello!"
			expect(t:GetType()).to.equal(TableTypes.Mixed)
		end)
		
		it("should update an dictionary table to a mixed table", function()
			local t = BetterTables.new()
			t["Yay!"] = "Hello!"
			expect(t:GetType()).to.equal(TableTypes.Dictionary)
			t:Insert("Hello!")
			expect(t:GetType()).to.equal(TableTypes.Mixed)
		end)
		
		it("should update a mixed table to a dictionary table", function()
			local t = BetterTables.new()
			t["Yay!"] = "Hello!"
			t:Insert("Hello!")
			expect(t:GetType()).to.equal(TableTypes.Mixed)
			t:Remove(1)
			expect(t:GetType()).to.equal(TableTypes.Dictionary)
		end)
		
		it("should update a mixed table to an array table", function()
			local t = BetterTables.new()
			t["Yay!"] = "Hello!"
			t:Insert("Hello!")
			expect(t:GetType()).to.equal(TableTypes.Mixed)
			t["Yay!"] = nil
			expect(t:GetType()).to.equal(TableTypes.Array)
		end)
		
		it("should find a value which is greater than 5 in an array table", function()
			local t = BetterTables.new()
			local v = math.random(6,100)
			t:Insert(v)
			for i = 1, 100 do
				t:Insert(math.random(0,5))
			end
			local val = t:Find(function(value, index, tbl)
				if value > 5 then
					return true
				end
				return false
			end)
			expect(val).to.equal(v)
		end)
		
		it("should find the value of a key which is has a length of 8 in a dictionary table", function()
			local t = BetterTables.new()
			t["Hello"] = 5
			t["Goodbye"] = 10
			t["a"] = 0
			t["good bye"] = 4
			t["no"] = 7
			local val = t:Find(function(value, key, tbl)
				if #key == 8 then
					return true
				end
				return false
			end)
			expect(val).to.equal(4)
		end)
		
		it("should find the index of the first value equal to 8", function()
			local t = BetterTables.new()
			t:Insert(3)
			t:Insert(6)
			t:Insert(8)
			t:Insert(9)
			t:Insert(4)
			t:Insert(7)
			local index = t:FindIndex(8)
			expect(index).to.equal(3)
		end)
		
		it("should find the index of the first value greater than 8", function()
			local t = BetterTables.new()
			t:Insert(3)
			t:Insert(6)
			t:Insert(8)
			t:Insert(9)
			t:Insert(4)
			t:Insert(7)
			local index = t:FindIndex(function(value, key, tbl)
				if value > 8 then
					return true
				end
				return false
			end)
			expect(index).to.equal(4)
		end)
		
		it("should find the key of the first value equal to 'yay!'", function()
			local t = BetterTables.new()
			t["no"] = "yes"
			t["goodbye"] = "hello"
			t["happy"] = "sad"
			t["test"] = "yay!"
			t["x"] = "y"
			t["z"] = "a"
			local key = t:FindKey("yay!")
			expect(key).to.equal("test")
		end)
		
		it("should find the key of the first value with a length greater than 8", function()
			local t = BetterTables.new()
			t["no"] = "yes"
			t["goodbye"] = "hello"
			t["happy"] = "sad"
			t["test"] = "yay but with extra padding!"
			t["x"] = "y"
			t["z"] = "a"
			local key = t:FindKey(function(value, key, tbl)
				if #value > 8 then
					return true
				end
				return false
			end)
			expect(key).to.equal("test")
		end)
		
		it("should create a deep copy", function()
			local t = BetterTables.new()
			local x = {5}
			t:Insert(x)
			local copy = t:DeepCopy()
			expect(copy[1]).never.to.equal(x)
		end)
		
		it("should create a shallow copy", function()
			local t = BetterTables.new()
			local x = {5}
			t:Insert(x)
			local copy = t:ShallowCopy()
			expect(copy[1]).to.equal(x)
		end)
		
		it("should fill from indecies 5 to 10 with 'yay!'", function()
			local t = BetterTables.new()
			for i = 1, 5 do
				t:Insert("noooo!")
			end
			expect(t[5]).to.equal("noooo!")
			t:Fill("yay!", 5, 10)
			for i = 5, 10 do
				expect(t[i]).to.equal("yay!")
			end
		end)
		
		it("should properly return that every value is greater than 5", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(6,100))
			end
			local everyValueGreaterThan5 = t:Every(function(value)
				if value > 5 then return true end
				return false
			end)
			expect(everyValueGreaterThan5).to.equal(true)
		end)
		
		it("should properly return that not every value is greater than 5", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(6,100))
			end
			t:Insert(5)
			local everyValueGreaterThan5 = t:Every(function(value)
				if value > 5 then return true end
				return false
			end)
			expect(everyValueGreaterThan5).to.equal(false)
		end)
		
		it("should properly return that some value is greater than 5", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(0,5))
			end
			t:Insert(6)
			local someValueGreaterThan5 = t:Some(function(value)
				if value > 5 then return true end
				return false
			end)
			expect(someValueGreaterThan5).to.equal(true)
		end)
		
		it("should properly return that no value is greater than 5", function()
			local t = BetterTables.new()
			for i = 1, 100 do
				t:Insert(math.random(0,5))
			end
			local someValueGreaterThan5 = t:Some(function(value)
				if value > 5 then return true end
				return false
			end)
			expect(someValueGreaterThan5).to.equal(false)
		end)
		
		it("should properly remove all values equal to 5 from the table", function()
			local t = BetterTables.new()
			for i = 1, 10 do
				t:Insert(5)
			end
			t:Insert(3)
			t:Filter(function(value)
				return value ~= 5
			end)
			expect(t[1])
		end)
		
		it("should concatenate an array better table and an array regular table together", function()
			local t = BetterTables.new()
			t:Insert(3)
			
			local t2 = {5}
			
			t:Concat(t2)
			
			expect(t[1]).to.equal(3)
			expect(t[2]).to.equal(5)
		end)
		
		it("should concatenate two array better tables together", function()
			local t = BetterTables.new()
			t:Insert(3)

			local t2 = BetterTables.new()
			t2:Insert(5)

			t:Concat(t2)

			expect(t[1]).to.equal(3)
			expect(t[2]).to.equal(5)
		end)
		
		it("should concatenate an array better table and a dictionary together", function()
			local t = BetterTables.new()
			t:Insert(3)

			local t2 = {}
			t2["yes"] = "no"

			t:Concat(t2)

			expect(t[1]).to.equal(3)
			expect(t["yes"]).to.equal("no")
		end)
		
		it("should concatenate an array better table and a mixed table together (overriding occurs)", function()
			local t = BetterTables.new()
			t:Insert(3)
			t:Insert(5)

			local t2 = {}
			table.insert(t2, "hi")
			t2["yes"] = "no"

			t:Concat(t2)

			expect(t[1]).to.equal("hi")
			expect(t[2]).to.equal(5)
			expect(t["yes"]).to.equal("no")
		end)
		
		--[[
			Shuffle is completely random, and there is a (very slim) chance that it just
			doesn't move at all. However, in my tests it did work, but adding a unit test to
			a randomized function is not ideal.
		]]
	end)
end