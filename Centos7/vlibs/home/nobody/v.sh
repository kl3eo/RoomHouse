#!/bin/bash

f=a$1.js
#cd ~/vchat_video/src/main/resources/static/js/ && terser conferenceroom_144a.js participant_139a.js i18n_120.js kure.js starter_a.js --compress --mangle > $f && rm -f conferenceroom_144a.js participant_139a.js i18n_120.js kure.js starter_a.js && cd .. && rsync -az --delete ./ ~/vchat_video/target/classes/static/ && cd

cd ~/vchat_video/src/main/resources/static/js/ && rm -f conferenceroom_144a.js participant_139a.js i18n_120.js kure.js starter_a.js && cd .. && rsync -az --delete ./ ~/vchat_video/target/classes/static/ && cd
