return function()
  local msgpack = require(script.Parent.msgpack)

  describe("decode", function()
    it("can decode nil value", function()
      local message = "\xC0"
      expect(msgpack.decode(message)).to.equal(nil)
    end)

    it("can decode false value", function()
      local message = "\xC2"
      expect(msgpack.decode(message)).to.equal(false)
    end)

    it("can decode true value", function()
      local message = "\xC3"
      expect(msgpack.decode(message)).to.equal(true)
    end)

    it("can decode positive fixint value", function()
      expect(msgpack.decode("\x0C")).to.equal(12)
      expect(msgpack.decode("\x00")).to.equal(0)
      expect(msgpack.decode("\x7f")).to.equal(127)
    end)

    it("can decode negative fixint value", function()
      expect(msgpack.decode("\xE0")).to.equal(-32)
      expect(msgpack.decode("\xFF")).to.equal(-1)
      expect(msgpack.decode("\xE7")).to.equal(-25)
    end)

    it("can decode uint 8 value", function()
      expect(msgpack.decode("\xCC\x00")).to.equal(0)
      expect(msgpack.decode("\xCC\xFF")).to.equal(255)
      expect(msgpack.decode("\xCC\x0F")).to.equal(15)
    end)

    it("can decode uint 16 value", function()
      expect(msgpack.decode("\xCD\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xCD\xFF\xFF")).to.equal(65535)
      expect(msgpack.decode("\xCD\x00\xFF")).to.equal(255)
    end)

    it("can decode uint 32 value" function()
      expect(msgpack.decode("\xCE\x00\x00\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xCE\xFF\xFF\xFF\xFF")).to.equal(4294967295)
      expect(msgpack.decode("\xCE\x00\x00\xFF\xFF")).to.equal(65535)
    end)

    it("can decode uint 64 value", function()
      local zeroValue = msgpack.decode("\xCF\x00\x00\x00\x00\x00\x00\x00\x00")
      expect(zeroValue._msgpackType).to.equal(msgpack.UInt64)
      expect(zeroValue.mostSignificantPart).to.equal(0)
      expect(zeroValue.leastSignificantPart).to.equal(0)

      local maxValue = msgpack.decode("\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")
      expect(maxValue.mostSignificantPart).to.equal(4294967295)
      expect(maxValue.leastSignificantPart).to.equal(4294967295)

      local midValue = msgpack.decode("\xCF\x00\x00\x00\x00\xFF\xFF\xFF\xFF")
      expect(midValue.mostSignificantPart).to.equal(0)
      expect(midValue.leastSignificantPart).to.equal(4294967295)
    end)

    it("can decode int 8 value", function()
      expect(msgpack.decode("\xD0\x00")).to.equal(0)
      expect(msgpack.decode("\xD0\xFF")).to.equal(-1)
      expect(msgpack.decode("\xD0\x0F")).to.equal(15)
      expect(msgpack.decode("\xD0\x7F")).to.equal(127)
      expect(msgpack.decode("\xD0\x80")).to.equal(-128)
    end)

    it("can decode int 16 value", function()
      expect(msgpack.decode("\xD1\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xD1\xFF\xFF")).to.equal(-1)
      expect(msgpack.decode("\xD1\x00\xFF")).to.equal(255)
      expect(msgpack.decode("\xD1\x7F\xFF")).to.equal(32767)
      expect(msgpack.decode("\xD1\x80\x00")).to.equal(-32768)
    end)

    it("can decode int 32 value", function()
      expect(msgpack.decode("\xD2\x00\x00\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xD2\xFF\xFF\xFF\xFF")).to.equal(-1)
      expect(msgpack.decode("\xD2\x00\x00\xFF\xFF")).to.equal(65535)
      expect(msgpack.decode("\xD2\x7F\xFF\xFF\xFF")).to.equal(2147483647)
      expect(msgpack.decode("\xD2\x80\x00\x00\x00")).to.equal(-2147483648)
    end)

    it("can decode int 64 value", function()
      local zeroValue = msgpack.decode("\xD3\x00\x00\x00\x00\x00\x00\x00\x00")
      expect(zeroValue._msgpackType).to.equal(msgpack.Int64)
      expect(zeroValue.mostSignificantPart).to.equal(0)
      expect(zeroValue.leastSignificantPart).to.equal(0)

      local maxValue = msgpack.decode("\xD3\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF")
      expect(maxValue.mostSignificantPart).to.equal(4294967295)
      expect(maxValue.leastSignificantPart).to.equal(4294967295)

      local midValue = msgpack.decode("\xD3\x00\x00\x00\x00\xFF\xFF\xFF\xFF")
      expect(midValue.mostSignificantPart).to.equal(0)
      expect(midValue.leastSignificantPart).to.equal(4294967295)
    end)

    it("can decode float 32 value", function()
      expect(msgpack.decode("\xCA\x00\x00\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xCA\x40\x00\x00\x00")).to.equal(2)
      expect(msgpack.decode("\xCA\xC0\x00\x00\x00")).to.equal(-2)
      expect(msgpack.decode("\xCA\x78\x00\x00\x00")).to.equal(math.huge)
      expect(msgpack.decode("\xCA\xF8\x00\x00\x00")).to.equal(-math.huge)

      local nan = msgpack.decode("\xCA\xF8\x00\x00\x01")
      expect(nan).to.never.equal(nan)
    end)

    it("can decode float 64 value", function()
      expect(msgpack.decode("\xCB\x00\x00\x00\x00\x00\x00\x00\x00")).to.equal(0)
      expect(msgpack.decode("\xCB\x40\x00\x00\x00\x00\x00\x00\x00")).to.equal(2)
      expect(msgpack.decode("\xCB\xC0\x00\x00\x00\x00\x00\x00\x00")).to.equal(-2)
      expect(msgpack.decode("\xCB\x7F\xF0\x00\x00\x00\x00\x00\x00")).to.equal(math.huge)
      expect(msgpack.decode("\xCB\xFF\xF0\x00\x00\x00\x00\x00\x00")).to.equal(-math.huge)

      local nan = msgpack.decode("\xCB\xFF\xF0\x00\x00\x00\x00\x00\x01")
      expect(nan).to.never.equal(nan)
    end)

    it("can decode fixstr value", function()
      except(msgpack.decode("\xA0")).to.equal("")
      except(msgpack.decode("\xA1\x78")).to.equal("x")
      except(msgpack.decode("\xAB\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")).to.equal("hello world")
      except(msgpack.decode("\xBF\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61\x61")).to.equal("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    end)

    it("can decode str 8 value", function()
      except(msgpack.decode("\xD9\x00")).to.equal("")
      except(msgpack.decode("\xD9\x01\x78")).to.equal("x")
      except(msgpack.decode("\xD9\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")).to.equal("hello world")
    end)

    it("can decode str 16 value", function()
      except(msgpack.decode("\xDA\x00\x00")).to.equal("")
      except(msgpack.decode("\xDA\x00\x01\x78")).to.equal("x")
      except(msgpack.decode("\xDA\x00\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")).to.equal("hello world")
    end)

    it("can decode str 32 value", function()
      except(msgpack.decode("\xDB\x00\x00\x00\x00")).to.equal("")
      except(msgpack.decode("\xDB\x00\x00\x00\x01\x78")).to.equal("x")
      except(msgpack.decode("\xDB\x00\x00\x00\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")).to.equal("hello world")
    end)

    it("can decode bin 8 value", function()
      local emptyBinary = msgpack.decode("\xC4\x00")
      expect(emptyBinary._msgpackType).to.equal(msgpack.ByteArray)
      expect(emptyBinary.data).to.equal("")

      local xBinary = msgpack.decode("\xC4\x01\x78")
      except(xBinary.data).to.equal("x")

      local helloBinary = msgpack.decode("\xC4\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")
      except(helloBinary.data).to.equal("hello world")
    end)

    it("can decode bin 16 value", function()
      local emptyBinary = msgpack.decode("\xC5\x00\x00")
      expect(emptyBinary._msgpackType).to.equal(msgpack.ByteArray)
      expect(emptyBinary.data).to.equal("")

      local xBinary = msgpack.decode("\xC5\x00\x01\x78")
      except(xBinary.data).to.equal("x")

      local helloBinary = msgpack.decode("\xC5\x00\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")
      except(helloBinary.data).to.equal("hello world")
    end)

    it("can decode bin 32 value", function()
      local emptyBinary = msgpack.decode("\xC6\x00\x00\x00\x00")
      expect(emptyBinary._msgpackType).to.equal(msgpack.ByteArray)
      expect(emptyBinary.data).to.equal("")

      local xBinary = msgpack.decode("\xC6\x00\x00\x00\x01\x78")
      except(xBinary.data).to.equal("x")

      local helloBinary = msgpack.decode("\xC6\x00\x00\x00\x0B\x68\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")
      except(helloBinary.data).to.equal("hello world")
    end)

    it("can decode fixarray value", function()
      local emptyArray = msgpack.decode("\x90")
      expect(emptyArray).to.be.a("table")
      expect(#emptyArray).to.equal(0)
      expect(next(emptyArray)).never.to.be.ok()

      local filledArray = msgpack.decode("\x93\xC0\xC2\xC3")
      expect(#filledArray).to.equal(3)
      expect(filledArray[1]).to.equal(nil)
      expect(filledArray[2]).to.equal(false)
      expect(filledArray[3]).to.equal(true)

      local arrayWithString = msgpack.decode("\x93\xC2\xA5\x68\x65\x6C\x6C\x6F\xC3")
      expect(#arrayWithString).to.equal(3)
      expect(arrayWithString[1]).to.equal(false)
      expect(arrayWithString[2]).to.equal("hello")
      expect(arrayWithString[3]).to.equal(true)
    end)

    it("can decode array 16 value", function()
      local emptyArray = msgpack.decode("\xDC\x00\x00")
      expect(emptyArray).to.be.a("table")
      expect(#emptyArray).to.equal(0)
      expect(next(emptyArray)).never.to.be.ok()

      local filledArray = msgpack.decode("\xDC\x00\x03\xC0\xC2\xC3")
      expect(#filledArray).to.equal(3)
      expect(filledArray[1]).to.equal(nil)
      expect(filledArray[2]).to.equal(false)
      expect(filledArray[3]).to.equal(true)

      local arrayWithString = msgpack.decode("\xDC\x00\x03\xC2\xA5\x68\x65\x6C\x6C\x6F\xC3")
      expect(#arrayWithString).to.equal(3)
      expect(arrayWithString[1]).to.equal(false)
      expect(arrayWithString[2]).to.equal("hello")
      expect(arrayWithString[3]).to.equal(true)
    end)

    it("can decode array 32 value", function()
      local emptyArray = msgpack.decode("\xDD\x00\x00\x00\x00")
      expect(emptyArray).to.be.a("table")
      expect(#emptyArray).to.equal(0)
      expect(next(emptyArray)).never.to.be.ok()

      local filledArray = msgpack.decode("\xDD\x00\x00\x00\x03\xC0\xC2\xC3")
      expect(#filledArray).to.equal(3)
      expect(filledArray[1]).to.equal(nil)
      expect(filledArray[2]).to.equal(false)
      expect(filledArray[3]).to.equal(true)

      local arrayWithString = msgpack.decode("\xDD\x00\x00\x00\x03\xC2\xA5\x68\x65\x6C\x6C\x6F\xC3")
      expect(#arrayWithString).to.equal(3)
      expect(arrayWithString[1]).to.equal(false)
      expect(arrayWithString[2]).to.equal("hello")
      expect(arrayWithString[3]).to.equal(true)
    end)

    it("can decode fixmap value", function()
      local emptyMap = msgpack.decode("\x80")
      expect(emptyMap).to.be.a("table")
      expect(#emptyMap).to.equal(0)
      expect(next(emptyMap)).never.to.be.ok()

      local filledMap = msgpack.decode("\x82\xA5\x68\x65\x6C\x6C\x6F\xA5\x77\x6F\x72\x6C\x64\x7B\xC3")
      expect(#filledMap).to.equal(0)
      expect(next(filledMap)).to.be.ok()
      expect(filledMap["hello"]).to.equal("world")
      expect(filledMap[123]).to.equal(true)
    end)

    it("can decode map 16 value", function()
      local emptyMap = msgpack.decode("\xDE\x00\x00")
      expect(emptyMap).to.be.a("table")
      expect(#emptyMap).to.equal(0)
      expect(next(emptyMap)).never.to.be.ok()

      local filledMap = msgpack.decode("\xDE\x00\x02\xA5\x68\x65\x6C\x6C\x6F\xA5\x77\x6F\x72\x6C\x64\x7B\xC3")
      expect(#filledMap).to.equal(0)
      expect(next(filledMap)).to.be.ok()
      expect(filledMap["hello"]).to.equal("world")
      expect(filledMap[123]).to.equal(true)
    end)

    it("can decode map 32 value", function()
      local emptyMap = msgpack.decode("\xDF\x00\x00\x00\x00")
      expect(emptyMap).to.be.a("table")
      expect(#emptyMap).to.equal(0)
      expect(next(emptyMap)).never.to.be.ok()

      local filledMap = msgpack.decode("\xDF\x00\x00\x00\x02\xA5\x68\x65\x6C\x6C\x6F\xA5\x77\x6F\x72\x6C\x64\x7B\xC3")
      expect(#filledMap).to.equal(0)
      expect(next(filledMap)).to.be.ok()
      expect(filledMap["hello"]).to.equal("world")
      expect(filledMap[123]).to.equal(true)
    end)

    it("can decode fixext 1 value", function()
      local extension = msgpack.decode("\xD4\x7B\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("x")
    end)

    it("can decode fixext 2 value", function()
      local extension = msgpack.decode("\xD5\x7B\x78\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("xx")
    end)

    it("can decode fixext 4 value", function()
      local extension = msgpack.decode("\xD6\x7B\x78\x78\x78\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("xxxx")
    end)

    it("can decode fixext 8 value", function()
      local extension = msgpack.decode("\xD6\x7B\x78\x78\x78\x78\x78\x78\x78\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("xxxxxxxx")
    end)

    it("can decode fixext 16 value", function()
      local extension = msgpack.decode("\xD6\x7B\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("xxxxxxxxxxxxxxxx")
    end)

    it("can decode ext 8 value", function()
      local emptyExtension = msgpack.decode("\xC7\x00\x7B")
      expect(emptyExtension._msgpackType).to.equal(msgpack.Extension)
      expect(emptyExtension.type).to.equal(123)
      expect(emptyExtension.data).to.equal("")

      local extension = msgpack.decode("\xC7\x01\x7B\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("x")
    end)

    it("can decode ext 16 value", function()
      local emptyExtension = msgpack.decode("\xC8\x00\x00\x7B")
      expect(emptyExtension._msgpackType).to.equal(msgpack.Extension)
      expect(emptyExtension.type).to.equal(123)
      expect(emptyExtension.data).to.equal("")

      local extension = msgpack.decode("\xC8\x00\x01\x7B\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("x")
    end)

    it("can decode ext 32 value", function()
      local emptyExtension = msgpack.decode("\xC9\x00\x00\x00\x00\x7B")
      expect(emptyExtension._msgpackType).to.equal(msgpack.Extension)
      expect(emptyExtension.type).to.equal(123)
      expect(emptyExtension.data).to.equal("")

      local extension = msgpack.decode("\xC9\x00\x00\x00\x01\x7B\x78")
      expect(extension._msgpackType).to.equal(msgpack.Extension)
      expect(extension.type).to.equal(123)
      expect(extension.data).to.equal("x")
    end)
  end)

  describe("encode", function()
  end)
end
