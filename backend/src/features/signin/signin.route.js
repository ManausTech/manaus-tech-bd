import express from 'express'
import signInController from './signin.controller.js';
const signInRouter = express.Router();
signInRouter.post('/', signInController)
export default signInRouter