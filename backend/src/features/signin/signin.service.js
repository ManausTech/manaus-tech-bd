import { findByEmail } from "../../shared/users/repositories/users.repository.js";
import { comparePassword } from "../../core/security/password.service.js";
import { generateToken } from "../../core/security/jwt.service.js";

async function signIn(email, password) {
    if (typeof email === "string") {
        email = email.trim().toLowerCase();
    }

    const user = await findByEmail(email);

    if (!user) {
        const error = new Error("Email ou senha inválidos");
        error.statusCode = 401;
        throw error;
    }
    const isPasswordCorrect = await comparePassword(password, user.password);
    if (!isPasswordCorrect) {
        const error = new Error("Email ou senha inválidos");
        error.statusCode = 401;
        throw error;
    }

    if (user.status !== "ACTIVE") {
        const error = new Error("Conta inativa");
        error.statusCode = 403;
        throw error;
    }

    const { password: _, ...safeUser } = user;

    try {
        const token = generateToken(user);
        return {
            token, user: safeUser
        };
    } catch (issue) {
        const error = new Error("Erro Interno: " + issue.message);
        error.statusCode = 500;
        throw error;
    }
}

export default signIn