import { beforeEach, describe, expect, it, jest } from "@jest/globals";

const mockFindByEmail = jest.fn();
const mockComparePassword = jest.fn();
const mockGenerateToken = jest.fn();

jest.unstable_mockModule("../../../src/shared/users/repositories/users.repository.js", () => ({
    findByEmail: mockFindByEmail,
}));
jest.unstable_mockModule("../../../src/core/security/password.service.js", () => ({
    comparePassword: mockComparePassword,
}));
jest.unstable_mockModule("../../../src/core/security/jwt.service.js", () => ({
    generateToken: mockGenerateToken,
}));

const { default: signIn } = await import("../../../src/features/signin/signin.service.js");

describe("signIn - status e normalizacao de email", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it("deve bloquear conta inativa com 403 e nao gerar token", async () => {
        mockFindByEmail.mockResolvedValue({ id: "1", email: "a@b.com", password: "hash", status: "INACTIVE" });
        mockComparePassword.mockResolvedValue(true);

        await expect(signIn("a@b.com", "123456")).rejects.toMatchObject({
            statusCode: 403,
            message: "Conta inativa",
        });
        expect(mockGenerateToken).not.toHaveBeenCalled();
    });

    it("deve devolver 401 (e nao 403) quando a senha esta errada em conta inativa", async () => {
        mockFindByEmail.mockResolvedValue({ id: "1", email: "a@b.com", password: "hash", status: "INACTIVE" });
        mockComparePassword.mockResolvedValue(false);

        await expect(signIn("a@b.com", "errada")).rejects.toMatchObject({ statusCode: 401 });
    });

    it("deve normalizar o email antes de buscar o usuario", async () => {
        mockFindByEmail.mockResolvedValue(null);

        await expect(signIn("  TESTE@Email.com ", "123456")).rejects.toMatchObject({ statusCode: 401 });
        expect(mockFindByEmail).toHaveBeenCalledWith("teste@email.com");
    });

    it("deve logar conta ativa e nao devolver a senha", async () => {
        mockFindByEmail.mockResolvedValue({ id: "1", email: "a@b.com", password: "hash", status: "ACTIVE" });
        mockComparePassword.mockResolvedValue(true);
        mockGenerateToken.mockReturnValue("token-falso");

        const result = await signIn("a@b.com", "123456");

        expect(result.token).toBe("token-falso");
        expect(result.user).not.toHaveProperty("password");
    });
});