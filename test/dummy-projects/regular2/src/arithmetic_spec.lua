local arithmetic = require 'arithmetic'

describe('Arithmetic', function()
	it('Adds two numbers', function()
		assert.are.equal(5, arithmetic.add(2, 3))
	end)
	it('Multiplies two numbers', function()
		assert.are.equal(6, arithmetic.multiply(2, 3))
	end)
end)
