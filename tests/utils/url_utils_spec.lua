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

describe("url_utils", function()
    describe("urlencode", function()
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
            -- The actual implementation doesn't encode . (dot)
            local input = "test@example.com"

            -- Act
            local result = url_utils.urlencode(input)

            -- Assert
            assert.are.equal("test%40example.com", result)
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
            -- The actual implementation preserves: - _ . ~
            -- These are "unreserved" characters per RFC 3986
            local input = "test-file_name.txt"

            -- Act
            local result = url_utils.urlencode(input)

            -- Assert
            assert.are.equal("test-file_name.txt", result)
        end)

        it("encodes unicode characters", function()
            -- Arrange
            local input = "hello世界"

            -- Act
            local result = url_utils.urlencode(input)

            -- Assert
            -- Unicode characters should be percent-encoded
            -- Just verify the result contains % signs (percent encoding)
            assert.is_true(result:find("%%") ~= nil)
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

    describe("encode_query", function()
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
            }

            -- Act
            local result = url_utils.encode_query(params)

            -- Assert
            -- Order may vary, check both keys are present
            assert.is_true(result:find("type=maven%-project") ~= nil)
            assert.is_true(result:find("language=java") ~= nil)
            assert.is_true(result:find("&") ~= nil)
        end)

        it("encodes values with special characters", function()
            -- Arrange
            local params = {
                name = "My Project",
                description = "A test project!",
            }

            -- Act
            local result = url_utils.encode_query(params)

            -- Assert
            -- Check that spaces and special chars are encoded
            assert.is_true(result:find("My%%20Project") ~= nil)
            assert.is_true(result:find("test%%20project%%21") ~= nil)
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
            -- Commas are encoded as %2C
            -- Hyphens are NOT encoded (unreserved character)
            assert.are.equal("dependencies=web%2Cdata-jpa%2Csecurity", result)
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
            -- Numbers as strings should be preserved
            assert.is_true(result:find("javaVersion=17") ~= nil)
            assert.is_true(result:find("port=8080") ~= nil)
        end)
    end)
end)
