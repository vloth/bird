const sharp = require('sharp')
const { promisify } = require('util')
const fs = require('fs')

const readdir = promisify(fs.readdir)
const copy = promisify(fs.copyFile)

async function main() {
  const files = await readdir('../out/')

  const copies = files.map(x => copy(`../out/${x}`, `src/assets/out/${x}`))
  const thumbs = files.map(x => sharp(`../out/${x}`) .resize(480)
     .png({ progressive: true, quality: 45 })
     .toFile(`src/assets/thumb/${x}`))

  await Promise.all(copies.concat(thumbs))
}

main()
