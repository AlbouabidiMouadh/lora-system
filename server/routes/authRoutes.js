const express = require("express");
const router = express.Router();
const {
  register,
  login,
  updatePassword,
  forgotPassword,
  resetPassword,
  logout
} = require("../controllers/authController");
const { protect } = require("../middlewares/auth");

router.post("/register", register);
router.post("/login", login);
router.get('/logout', protect, logout);
router.put("/updatepassword", protect, updatePassword);
router.post("/forgotpassword", forgotPassword);
router.put("/resetpassword/:resettoken", resetPassword);

module.exports = router;
