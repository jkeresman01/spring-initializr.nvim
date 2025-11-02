----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--
-- Unit tests for spring-initializr/utils/url_utils.lua
--
----------------------------------------------------------------------------

local url_utils = require("spring-initializr.utils.url_utils")

describe("url_utils.urlencode", function()
    it("encodes spaces as %20", function()
        -- Arrange
        local input = "hello world"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("hello%20world", result)
    end)

    it("encodes special characters correctly", function()
        -- Arrange
        local input = "a=b&c=d"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("a%3Db%26c%3Dd", result)
    end)

    it("preserves alphanumeric characters", function()
        -- Arrange
        local input = "abc123XYZ"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("abc123XYZ", result)
    end)

    it("preserves allowed special characters", function()
        -- Arrange
        local input = "test-file_name.txt~"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("test-file_name.txt~", result)
    end)

    it("encodes unicode characters", function()
        -- Arrange
        local input = "hello™"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.is_true(result:match("%%"))
    end)

    it("handles empty string", function()
        -- Arrange
        local input = ""

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("", result)
    end)

    it("encodes forward slash", function()
        -- Arrange
        local input = "path/to/file"

        -- Act
        local result = url_utils.urlencode(input)

        -- Assert
        assert.are.equal("path%2Fto%2Ffile", result)
    end)
end)

describe("url_utils.encode_query", function()
    it("encodes single key-value pair", function()
        -- Arrange
        local params = { name = "test" }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.are.equal("name=test", result)
    end)

    it("encodes multiple key-value pairs", function()
        -- Arrange
        local params = {
            type = "maven-project",
            language = "java",
            bootVersion = "3.2.0",
        }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.is_true(result:match("type=maven%-project"))
        assert.is_true(result:match("language=java"))
        assert.is_true(result:match("bootVersion=3%.2%.0"))
    end)

    it("encodes values with special characters", function()
        -- Arrange
        local params = {
            description = "Demo project for Spring Boot",
            groupId = "com.example",
        }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.is_true(result:match("description=Demo%20project%20for%20Spring%20Boot"))
        assert.is_true(result:match("groupId=com%.example"))
    end)

    it("encodes empty value", function()
        -- Arrange
        local params = { key = "" }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.are.equal("key=", result)
    end)

    it("handles empty params table", function()
        -- Arrange
        local params = {}

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.are.equal("", result)
    end)

    it("encodes dependencies list", function()
        -- Arrange
        local params = {
            dependencies = "web,data-jpa,security",
        }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.are.equal("dependencies=web%2Cdata%-jpa%2Csecurity", result)
    end)

    it("encodes numeric values", function()
        -- Arrange
        local params = {
            javaVersion = "17",
            port = "8080",
        }

        -- Act
        local result = url_utils.encode_query(params)

        -- Assert
        assert.is_true(result:match("javaVersion=17"))
        assert.is_true(result:match("port=8080"))
    end)
end)
