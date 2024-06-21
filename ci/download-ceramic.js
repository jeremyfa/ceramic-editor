#!/usr/bin/env node

const childProcess = require('child_process');
const fs = require('fs');
const download = require('download');
const axios = require('axios');
const path = require('path');

process.chdir(path.join(__dirname, '..'));

const platform = process.platform === 'darwin' ? 'mac' : (process.platform === 'win32' ? 'windows' : 'linux');

function fail(message) {
    console.error(message);
    process.exit(1);
}

async function resolveLatestRelease() {

    var res = await axios.get('https://api.github.com/repos/ceramic-engine/ceramic/releases', { responseType: 'json' });
    var releases = res.data;

    for (var release of releases) {

        if (release.assets != null) {
            var assets = release.assets;
            for (var asset of assets) {
                if (asset.name == 'ceramic-' + platform + '.zip') {
                    return release;
                }
            }
        }
    }

    fail('Failed to resolve latest ceramic version! Try again later?');
    return null;

}

function cleanup() {
    if (fs.existsSync('ceramic.zip'))
        fs.unlinkSync('ceramic.zip');
    if (fs.existsSync('ceramic')) {
        if (platform === 'windows') {
            childProcess.execSync('rmdir /S /Q ceramic', { stdio: 'inherit' });
        } else {
            childProcess.execFileSync('rm', ['-rf', 'ceramic']);
        }
    }
}

function unzipFile(source, targetPath) {
    // if (platform === 'windows') {
    //     childProcess.execSync(`powershell -Command "Expand-Archive -Path '${source}' -DestinationPath '${targetPath}'"`, { stdio: 'inherit' });
    // } else {
        childProcess.execFileSync('unzip', ['-q', source, '-d', targetPath]);
    // }
}

cleanup();

(async () => {

    console.log('Resolve latest Ceramic release');
    var releaseInfo = await resolveLatestRelease();
    var targetTag = releaseInfo.tag_name;
    var ceramicZipPath = 'ceramic.zip';
    var ceramicArchiveUrl = 'https://github.com/ceramic-engine/ceramic/releases/download/' + targetTag + '/ceramic-' + platform + '.zip';

    console.log('Download ceramic archive: ' + ceramicArchiveUrl);
    fs.writeFileSync(ceramicZipPath, await download(ceramicArchiveUrl));

    console.log('Unzip...');
    unzipFile(ceramicZipPath, 'ceramic');

})();
