local electabuzz = {}

local utilities = require('otouto.utilities')

electabuzz.command = 'electabuzz'
electabuzz.doc = 'Returns an electabuzz pun.'

function electabuzz:init(config)
    electabuzz.triggers = utilities.triggers(self.info.username, 
config.cmd_pat):t('electabuzz').table
end

local selectabuzz = {
    "If people ate electabuzz, it would be delectabuzz",
    "If it was the proper thing to do it would be correctabuzz",
    "If electabuzz was voted to be the next president, well, he'd still be electabuzz",
    "If there was an electric drink, it would get you a little buzzed",
    "When electabuzz gets down to business he's directabuzz",
    "when electabuzz meets a girl he likes, he becomes erectabuzz",
    "When electabuzz goes door to door for a non-profit he's collectabuzz",
    "when electabuzz goes to a bar, he can expectabuzz",
    "If electabuzz got into an accident on the highway he'd be in a wrecktabuzz",
    "If electabuzz became a police detective, he'd be inspectabuzz",
    "If electabuzz began looking into himself for answers to life's biggest questions he'd be introspectabuzz",
    "If electabuzz caught zika, he'd be infectabuzz",
    "If electabuzz had a group, it would be a sectabuzz",
    "If electabuzz was a tasty treat he'd be a confectabuzz",
    "If electabuzz was in this group, he would have kektabuzz",
    "If electabuzz was learning another language he'd be learning a new dialectabuzz",
    "If electabuzz had no flaws he'd be a perfectabuzz",
    "If electabuzz built houses, he'd be an architectabuzz",
    "If electabuzz was learning more about an animal by cutting it open he'd be disectabuzz",
    "If electabuzz looked in a mirror, he'd be reflectabuzz",
    "If electabuzz was the center of attention, he'd be the subjectabuzz",
    "Looking back on things, electabuzz was a bit retrospectabuzz",
    "If electabuzz was cautious and calculating, he'd be circumspectabuzz",
    "If electabuzz looked at things from a new angle it would be a new perspectabuzz",
    "If electabuzz went to college, he'd be intellectabuzz",
    "If electabuzz was doing heroin, he'd have an injectabuzz",
    "If electabuzz posted the stallman pasta, he'd be interjectabuzz",
    "If electabuzz had super hearing, he'd be detectabuzz",
    "If electabuzz was brought back to life, he'd be resurrectabuzz",
    "If electabuzz didn't know how to tell you something he'd be indirectabuzz",
    "If electabuzz got a 100 on a test he'd be correctabuzz",
    "If electabuzz had an iron shield, he'd be deflectabuzz",
    "If ash chose electabuzz, he'd be selectabuzz",
    "If electabuzz was an bug he'd be insectabuzz",
    "If electabuzz was ignored he'd be neglectabuzz",
    "If electabuzz stopped talking to his friends he'd be disconnectabuzz",
    "If electabuzz heated things up he'd be convectabuzz",
    "If electabuzz had an important job he'd be respectabuzz",
    "If electabuzz was in a crime scene he'd be suspectabuzz",
    "If electabuzz came back for another term he'd be re-electabuzz",
    "If electabuzz went to mass he'd be genuflectabuzz",
    "If electabuzz used the internet he'd be connectabuzz",
    "If electabuzz was a hybrid with another pokemon he'd be genesectabuzz",
    "If electabuzz looked back at old memories, he'd be recollectabuzz",
    "If electabuzz crossed another electabuzz on a plane they would intersectabuzz",
    "If electabuzz's site had an error 301, it would be redirectabuzz",
    "If electabuzz took probability, he'd be prospectabuzz",
    "If electabuzz was damned to hell he'd be nonelectabuzz",
    "If electabuzz was in ace attorney he'd be objectabuzz",
    "If electabuzz didn't get a date he'd be rejectabuzz",
    "If electabuzz had to make an emergency escape he'd ejectabuzz",
    "If electabuzz made an error in a product it would be a defectabuzz",
    "If electabuzz had no pride he'd be abjectabuzz",
    "If electabuzz was in school he'd make a projectabuzz",
    "If electabuzz was a security guard he'd protectabuzz",
    "If electabuzz was depressed he'd be dejectabuzz"
}

function electabuzz:action(msg)
    utilities.send_reply(msg, selectabuzz[math.random(#selectabuzz)])
end

return electabuzz
