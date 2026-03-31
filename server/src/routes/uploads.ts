import { Router, Response } from 'express'
import multer from 'multer'
import path from 'path'
import fs from 'fs'
import { v4 as uuidv4 } from 'uuid'
import { authMiddleware, AuthRequest } from '../middleware/auth'

const router = Router()

// 确保上传目录存在
const uploadDir = path.join(__dirname, '../../uploads')
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

// 配置multer存储
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir)
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = uuidv4()
    const ext = path.extname(file.originalname)
    cb(null, `${Date.now()}-${uniqueSuffix}${ext}`)
  }
})

// 创建上传中间件
const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB限制
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf']
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true)
    } else {
      cb(new Error('只允许上传PDF文件'))
    }
  }
})

// 上传文件
router.post('/upload', authMiddleware, upload.single('file'), (req: AuthRequest, res: Response) => {
  try {
    if (!req.file) {
      res.status(400).json({ error: '没有文件上传' })
      return
    }

    const filePath = `/uploads/${req.file.filename}`
    res.json({
      success: true,
      filePath,
      filename: req.file.originalname
    })
  } catch (error) {
    console.error('上传文件错误:', error)
    res.status(500).json({ error: '上传失败' })
  }
})

// 下载文件
router.get('/download/:filename', authMiddleware, (req: AuthRequest, res: Response) => {
  try {
    const { filename } = req.params
    const filePath = path.join(uploadDir, filename)

    if (!fs.existsSync(filePath)) {
      res.status(404).json({ error: '文件不存在' })
      return
    }

    res.download(filePath)
  } catch (error) {
    console.error('下载文件错误:', error)
    res.status(500).json({ error: '下载失败' })
  }
})

// 预览文件
router.get('/preview/:filename', authMiddleware, (req: AuthRequest, res: Response) => {
  try {
    const { filename } = req.params
    const filePath = path.join(uploadDir, filename)

    if (!fs.existsSync(filePath)) {
      res.status(404).json({ error: '文件不存在' })
      return
    }

    res.setHeader('Content-Type', 'application/pdf')
    res.setHeader('Content-Disposition', `inline; filename=${filename}`)
    const fileStream = fs.createReadStream(filePath)
    fileStream.pipe(res)
  } catch (error) {
    console.error('预览文件错误:', error)
    res.status(500).json({ error: '预览失败' })
  }
})

export default router
