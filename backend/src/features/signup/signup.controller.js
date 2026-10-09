import signUpUser from "./signup.service.js";

async function signupController(req, res) {
    try {
        const { username, email, password } = req.body ?? {};
        const user = await signUpUser(username, email, password);
        res.status(201).json(user);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
}

export default signupController;
