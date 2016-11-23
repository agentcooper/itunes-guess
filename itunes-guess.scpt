// from https://gist.github.com/andrei-m/982927
function levenshtein(a, b) {
    var m = [], i, j, min = Math.min;

    if (!(a && b)) return (b || a).length;

    for (i = 0; i <= b.length; m[i] = [i++]);
    for (j = 0; j <= a.length; m[0][j] = j++);

    for (i = 1; i <= b.length; i++) {
        for (j = 1; j <= a.length; j++) {
            m[i][j] = b.charAt(i - 1) == a.charAt(j - 1)
                ? m[i - 1][j - 1]
                : m[i][j] = min(
                    m[i - 1][j - 1] + 1,
                    min(m[i][j - 1] + 1, m[i - 1 ][j] + 1))
        }
    }

    return m[b.length][a.length];
}

function userInput(s) {
	return s.trim().toLowerCase().replace('the ', '')
}

function textScore(count) {
	return count.correct + ' out of ' + (count.correct + count.wrong + count.skipped);
}

iTunes = Application('iTunes');

currentApp = Application.currentApplication();
currentApp.includeStandardAdditions = true;

var count = {
	wrong: 0,
	correct: 0,
	skipped: 0
};

function next() {
	iTunes.nextTrack();
	iTunes.sources["Library"].play();
	iTunes.playerPosition = 30;

	result = currentApp.displayDialog('Which artist is playing?', {
		withTitle: 'Guess the artist',
		defaultAnswer: '',
		buttons: ['Check', 'Don\'t know', 'Exit'],
		defaultButton: 1
	});

	if (result.buttonReturned === 'Exit') {
		iTunes.stop();
		return;
	}

	currentArtist = iTunes.currentTrack.artist();
	currentName = iTunes.currentTrack.name();
	prettyName = '"' + currentName + '" by "' + currentArtist + '"';

	if (result.buttonReturned === 'Don\'t know') {
		count.skipped++;
		currentApp.displayDialog(
			'This is ' + prettyName + '\n\n',
			{
				buttons: 'Next',
				defaultButton: 1
			}
		);
	} else {
		var result = levenshtein(userInput(result.textReturned), userInput(currentArtist)) <= 1;

		if (result) {
			count.correct++;
		} else {
			count.wrong++;
		}

		var output = result ? 'Correct' : 'Wrong';

		currentApp.displayDialog(
			output + ', this is ' + prettyName + '\n\n' + textScore(count),
			{
				buttons: 'Next',
				defaultButton: 1
			}
		);
	}

	next();
}

iTunes.shuffleEnabled = true;

next();
