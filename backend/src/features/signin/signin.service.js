import { findByEmail } from "../../shared/users/repositories/users.repository.js"
import { comparePassword } from "../../core/security/password.service.js";
import { generateToken } from "../../core/security/jwt.service.js";

async function signIn(email, password) {
    const user = await findByEmail(email);

    if (!user) {
        const error = new Error("Email não esta associado a uma conta");
        error.statusCode = 404;
        throw error;
    }
    const isPasswordCorrect = await comparePassword(password, user.password);
    if (!isPasswordCorrect) {
        const error = new Error("Senha incorreta");
        error.statusCode = 409;
        throw error;
    }

    const { password: _, ...safeUser } = user;

    try {
        const token = generateToken(user);
        return {
            token, user: safeUser
        }
    } catch (issue) {
        const error = new Error("Erro Interno: " + issue.message);
        error.statusCode = 500;
        throw error;
    }
}


export default signIn