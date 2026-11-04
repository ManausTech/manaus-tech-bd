import { beforeEach, describe, expect, it, jest } from "@jest/globals";

const mockValidateByUsername = jest.fn();
const mockValidateByEmail = jest.fn();
const mockCreateUser = jest.fn();
const mockHashPassword = jest.fn();

jest.unstable_mockModule("../../../src/shared/users/repositories/users.repository.js", () => ({
    validateByUsername: mockValidateByUsername,
    validateByEmail: mockValidateByEmail,
    createUser: mockCreateUser,
}));

jest.unstable_mockModule("../../../src/core/security/password.service.js", () => ({
    hashPassword: mockHashPassword,
}));

const { default: signUpUser } = await import("../../../src/features/signup/signup.service.js");

describe("signUpUser", () => {
    beforeEach(() => {
        jest.clearAllMocks();
        jest.spyOn(console, "error").mockImplementation(() => {});
        mockValidateByUsername.mockResolvedValue(false);
        mockValidateByEmail.mockResolvedValue(false);
        mockHashPassword.mockResolvedValue("hash-da-senha");
    });

    it("deve cadastrar o usuario com a senha em hash", async () => {
        mockCreateUser.mockResolvedValue({ id: 5n, username: "joao", status: "ACTIVE" });

        const result = await signUpUser("joao", "joao@email.com", "123456");

        expect(mockHashPassword).toHaveBeenCalledWith("123456");
        expect(mockCreateUser).toHaveBeenCalledWith({
            username: "joao",
            email: "joao@email.com",
            password: "hash-da-senha",
        });
        expect(result).toEqual({ id: "5", username: "joao", status: "ACTIVE" });
    });

    it("deve retornar 400 quando faltarem campos", async () => {
        await expect(signUpUser()).rejects.toMatchObject({
            statusCode: 400,
            message: "Campos nome de usuario, email e senha são obrigatorios",
        });
    });

    it("deve retornar 400 quando o email for invalido", async () => {
        await expect(signUpUser("joao", "invalido", "123456")).rejects.toMatchObject({
            statusCode: 400,
            message: "Email inválido",
        });
    });

    it("deve retornar 400 quando a senha for curta", async () => {
        await expect(signUpUser("joao", "joao@email.com", "123")).rejects.toMatchObject({
            statusCode: 400,
            message: "A senha deve ter pelo menos 6 caracteres",
        });
    });

    it("deve retornar 409 quando o nome de usuario ja existir", async () => {
        mockValidateByUsername.mockResolvedValue(true);

        await expect(signUpUser("joao", "joao@email.com", "123456")).rejects.toMatchObject({
            statusCode: 409,
            message: "Nome de usuario ja cadastrado",
        });
        expect(mockCreateUser).not.toHaveBeenCalled();
    });

    it("deve retornar 409 quando o email ja existir", async () => {
        mockValidateByEmail.mockResolvedValue(true);

        await expect(signUpUser("joao", "joao@email.com", "123456")).rejects.toMatchObject({
            statusCode: 409,
            message: "Email ja registrado",
        });
        expect(mockCreateUser).not.toHaveBeenCalled();
    });

    it("deve retornar 409 quando o banco recusar por duplicidade (P2002)", async () => {
        mockCreateUser.mockRejectedValue({ code: "P2002" });

        await expect(signUpUser("joao", "joao@email.com", "123456")).rejects.toMatchObject({
            statusCode: 409,
            message: "Usuario ou email ja cadastrado",
        });
    });

    it("deve retornar 500 quando o banco falhar por outro motivo", async () => {
        mockCreateUser.mockRejectedValue(new Error("falha qualquer"));

        await expect(signUpUser("joao", "joao@email.com", "123456")).rejects.toMatchObject({
            statusCode: 500,
            message: "Falha ao comunicar com banco de dados",
        });
    });
});