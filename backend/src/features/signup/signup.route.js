import express from 'express'
import signupController from './signup.controller.js'
const router = express.Router()
router.post('/', signupController)
export default router