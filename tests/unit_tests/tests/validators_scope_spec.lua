local validate_scope = require("kong.plugins.jwt-keycloak.validators.scope").validate_scope

local test_claims = {
    scope = "profile email dashed-scope"
}

describe("Validator", function()
    describe("for scope should", function()
        it("handle a when allowed scopes is nil", function()
            local valid, err = validate_scope("scope", nil, test_claims)
            assert.same(true, valid)
        end)

        it("handle a when allowed scopes is empty list", function()
            local valid, err = validate_scope("scope", {}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a when jwt claims is nil", function()
            local valid, err = validate_scope("scope", {"profile"}, nil)
            assert.same(nil, valid)
            assert.same("Missing required scope claim", err)
        end)

        it("handle a when scope claim is nil", function()
            local valid, err = validate_scope("scope", {"profile"}, {})
            assert.same(nil, valid)
            assert.same("Missing required scope claim", err)
        end)

        it("handle a when custom scope claim name", function()
            local my_claims = { scp = test_claims.scope}
            local valid, err = validate_scope("scp", {"profile"}, my_claims)
            assert.same(true, valid)
        end)

        it("handle a valid scope", function()
            local valid, err = validate_scope("scope", {"profile"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle a invalid scope", function()
            local valid, err = validate_scope("scope", {"account"}, test_claims)
            assert.same(nil, valid)
            assert.same("Missing required scope", err)
        end)

        it("handle a multiple scopes", function()
            local valid, err = validate_scope("scope", {"account", "email"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle pattern chars in scope", function()
            local valid, err = validate_scope("scope", {"dashed-scope"}, test_claims)
            assert.same(true, valid)
        end)

        it("handle partial scope match", function()
            local valid, err = validate_scope("scope", {"dashed"}, test_claims)
            assert.same(nil, valid)
            assert.same("Missing required scope", err)
        end)
    end)
end)