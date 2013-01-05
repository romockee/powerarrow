--
--    TODO: make these real unit tests that verify assertions
--
require('lib/couth')

--
--  mpc volume
--
require('lib/mpc')

print(couth.mpc:getVolume('pizza'))
print(couth.mpc:getVolume('localhost'))

--
--  alsa volume
--
require('lib/alsa')
couth.CONFIG.ALSA_CONTROLS = {
     'Master',
     'Headphone',
     'PCM',
     'Front'
}

print(couth.alsa:getVolume())
print('--------')
print(couth.alsa:getVolume('Master'))
