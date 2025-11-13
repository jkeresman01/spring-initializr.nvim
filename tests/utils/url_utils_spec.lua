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

local url_utils = require("spring-initializr.utils.url_utils")

describe("url_utils", function()
    describe("urlencode", function()
        it("encodes spaces as %20", function()
            local result = url_utils.urlencode("hello world")
            assert.are.equal("hello%20world", result)
        end)

        it("encodes special characters correctly", function()
            -- The actual implementation doesn't encode . (dot)
            local result = url_utils.urlencode("test@example.com")
            assert.are.equal("test%40example.com", result)
        end)

        it("preserves alphanumeric characters", function()
            local result = url_utils.urlencode("abc123XYZ")
            assert.are.equal("abc123XYZ", result)
        end)

        it("preserves allowed special characters", function()
            -- The actual implementation preserves: - _ . ~
            -- These are "unreserved" characters per RFC 3986
            local result = url_utils.urlencode("test-file_name.txt")
            assert.are.equal("test-file_name.txt", result)
        end)

        it("encodes unicode characters", function()
            local result = url_utils.urlencode("hello世界")
            -- Unicode characters should be percent-encoded
            -- Just verify the result contains % signs (percent encoding)
            assert.is_true(result:find("%%") ~= nil)
        end)

        it("handles empty string", function()
            local result = url_utils.urlencode("")
            assert.are.equal("", result)
        end)

        it("encodes forward slash", function()
            local result = url_utils.urlencode("path/to/file")
            assert.are.equal("path%2Fto%2Ffile", result)
        end)
    end)

    describe("encode_query", function()
        it("encodes single key-value pair", function()
            local params = { name = "test" }
            local result = url_utils.encode_query(params)
            assert.are.equal("name=test", result)
        end)

        it("encodes multiple key-value pairs", function()
            local params = {
                type = "maven-project",
                language = "java",
            }
            local result = url_utils.encode_query(params)

            -- Order may vary, check both keys are present
            assert.is_true(result:find("type=maven%-project") ~= nil)
            assert.is_true(result:find("language=java") ~= nil)
            assert.is_true(result:find("&") ~= nil)
        end)

        it("encodes values with special characters", function()
            local params = {
                name = "My Project",
                description = "A test project!",
            }
            local result = url_utils.encode_query(params)

            -- Check that spaces and special chars are encoded
            assert.is_true(result:find("My%%20Project") ~= nil)
            assert.is_true(result:find("test%%20project%%21") ~= nil)
        end)

        it("encodes empty value", function()
            local params = { key = "" }
            local result = url_utils.encode_query(params)
            assert.are.equal("key=", result)
        end)

        it("handles empty params table", function()
            local params = {}
            local result = url_utils.encode_query(params)
            assert.are.equal("", result)
        end)

        it("encodes dependencies list", function()
            local params = {
                dependencies = "web,data-jpa,security",
            }
            local result = url_utils.encode_query(params)

            -- Commas are encoded as %2C
            -- Hyphens are NOT encoded (unreserved character)
            assert.are.equal("dependencies=web%2Cdata-jpa%2Csecurity", result)
        end)

        it("encodes numeric values", function()
            local params = {
                javaVersion = "17",
                port = "8080",
            }
            local result = url_utils.encode_query(params)

            -- Numbers as strings should be preserved
            assert.is_true(result:find("javaVersion=17") ~= nil)
            assert.is_true(result:find("port=8080") ~= nil)
        end)
    end)
end)
