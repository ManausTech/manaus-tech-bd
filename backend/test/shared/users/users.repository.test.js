import { beforeEach, describe, expect, it, jest } from "@jest/globals";

const mockFindFirst = jest.fn();

jest.unstable_mockModule("../../../src/core/database/prisma.client.js", () => ({
    default: { users: { findFirst: mockFindFirst } },
}));

const { findByEmail } = await import("../../../src/shared/users/repositories/users.repository.js");

describe("findByEmail", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it("deve retornar null quando o email nao existir", async () => {
        mockFindFirst.mockResolvedValue(null);

        const result = await findByEmail("naoexiste@email.com");

        expect(mockFindFirst).toHaveBeenCalledWith({ where: { email: "naoexiste@email.com" } });
        expect(result).toBeNull();
    });

    it("deve retornar o usuario com o id convertido para texto", async () => {
        mockFindFirst.mockResolvedValue({ id: 7n, email: "joao@email.com", username: "joao" });

        const result = await findByEmail("joao@email.com");

        expect(result).toEqual({ id: "7", email: "joao@email.com", username: "joao" });
    });
});