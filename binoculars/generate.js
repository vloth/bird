const sharp = require('sharp')
const { promisify } = require('util')
const fs = require('fs')

const readFile = promisify(fs.readFile)
const readdir = promisify(fs.readdir)
const copy = promisify(fs.copyFile)
const writeFile = promisify(fs.writeFile)
const exists = promisify(fs.exists)
const mkdir = promisify(fs.mkdir)

async function main() {
  await Promise.all([
    ensureDirExists('build/assets/out'),
    ensureDirExists('build/assets/thumb'),
  ])

  const files = await readdir('../out')
  await Promise.all([copyFiles(files), copy('base.css', 'build/base.css')])

  const template = await readFile('index.html', { encoding: 'utf8' })
  await writeHtmlOut(template, files)
}

main()

function pathfy(file) {
  return file
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s/g , '-')
}

async function ensureDirExists(dir) {
  if (await exists(dir)) return
  return mkdir(dir, { recursive: true })
}

async function writeHtmlOut(baseHtml, birds) {
  const birdsHtml = birds.map(bird => `
    <div class='bird'>
      <img src="assets/thumb/${pathfy(bird)}.png" alt="" />
      <span class='description'>${bird}</span>
    </div>
   `).join('')
   const outHtml = baseHtml.replace('<birds />', birdsHtml);
   await writeFile('build/index.html', outHtml)
}

async function copyFiles(files) {
  // const copies = files.map(x => copy(`../out/${x}`, `build/assets/out/${pathfy(x)}`))
  const copies = []
  const thumbs = files.map(x => sharp(`../out/${x}`).resize(480)
     .png({ progressive: true, quality: 45 })
     .toFile(`build/assets/thumb/${pathfy(x)}.png`))

  return Promise.all(copies.concat(thumbs))
}

