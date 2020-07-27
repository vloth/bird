const sharp = require('sharp')
const { promisify } = require('util')
const fs = require('fs')

const readFile = promisify(fs.readFile)
const readdir = promisify(fs.readdir)
const copy = promisify(fs.copyFile)
const writeFile = promisify(fs.writeFile)
const exists = promisify(fs.exists)
const mkdir = promisify(fs.mkdir)

async function ensureDirExists(dir) {
  if (await exists(dir)) return
  return mkdir(dir)
}

async function writeHtmlOut(baseHtml, birds) {
    const birdsHtml = birds.map(bird => ```
      <div class='bird'>
        <img src="assets/thumb/${bird}" />
        <span class='description'>${bird}</span>
      </div>
    ```)
   const outHtml = baseHtml.replace('<birds />', birdsHtml);
   await writeFile('build/index.html', outHtml)
}

async function main() {
  const files = await readdir('../out/')

  const copies = files.map(x => copy(`../out/${x}`, `assets/out/${x}`))
  const thumbs = files.map(x => sharp(`../out/${x}`) .resize(480)
     .png({ progressive: true, quality: 45 })
     .toFile(`assets/thumb/${x}`))

  const files = Promise.all(copies.concat(thumbs))

  await ensureDirExists('build')
  await writeHtmlOut(await readFile('src/index.html'), files)
}

main()
