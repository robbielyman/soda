Soda_Bitters {
	classvar <notes, <inverse, <groups, <lastAction;
	
	*initClass {
		notes = 6.collect { Dictionary.new };
		inverse = 6.collect { IdentityDictionary.new };
		lastAction = 0;
		
		Startup.add {
			(Routine.new {
				10.yield;
				Server.default.sync;
				groups = 6.collect { Group.new };
				"SODA AND BITTERS ON THE ROCKS".postln;
			}).play;
			SynthDef(\soda_bitters, { |out|
				var gate = \gate.kr(0);
				var amp_env = Env.adsr(
					\attack.kr(0.0015),
					\decay.kr(0.8),
					\sustain.kr(0.7),
					\release.kr(0.131),
					\amp.kr(0.5)).kr(2, gate);
				var mod_env = Env.adsr(
					\mattack.kr(0.0015),
					\mdecay.kr(0.8),
					\msustain.kr(0.7),
					\mrelease.kr(0.131)).kr(0, gate);
				var lfo = LFTri.kr(\lfreq.kr(4.0), mul:Env.asr(\lfade.kr(0.0), 1, 10).kr(0, gate));
				var note = \note.kr(69);
				var mpitch = \mpitch.kr(0.0);
				var lpitch = \lpitch.kr(0.0);
				var freq1 = (note + \pitch1.kr(0.0) + (1.2 * mpitch * mod_env) + (1.2 * lpitch * lfo)).midicps;
				var freq2 = (note + \pitch2.kr(0.0) + (1.2 * mpitch * mod_env) + (1.2 * lpitch * lfo)).midicps;
				var fm1 = SinOsc.ar(
					freq:(ratio1 * freq1),
					mul:(\index1.kr(0.0) + (2.0 * \mindex1.kr(0.0) * mod_env) + (2.0 * \lindex1.kr(0.0) * lfo)));
				var fm2 = SinOsc.ar(
					freq:(ratio2 * freq2),
					mul:(\index2.kr(0.0) + (2.0 * \mindex2.kr(0.0) * mod_env) + (2.0 * \lindex2.kr(0.0) * lfo)));
				var pw1 = \width1.kr(0.5) + (0.5 * \mdwidth1.kr(0.0) * mod_env) + (0.5 * \lwidth1.kr(0.0) * lfo);
				var pw2 = \width2.kr(0.5) + (0.5 * \mdwidth2.kr(0.0) * mod_env) + (0.5 * \lwidth2.kr(0.0) * lfo);
				var sync = \sync.kr(0.0);
				var osc1 = \tri1.kr(1.0) * TrianglePTR.ar(freq:freq1, phase:fm1, width:pw1)
				+ \pulse1.kr(0.0) * PulsePTR.ar(freq:freq1, phase:fm1, width:pw1);
				var osc2 = \tri2.kr(1.0) * TrianglePTR.ar(freq:freq2, phase: fm2, sync:sync * osc1[1], width:pw2)
				+ \pulse2.kr(0.0) * PulsePTR.ar(freq:freq2, phase:fm2, sync:sync * osc1[1], width:pw2);
				var snd = LinXFade2.ar(osc1[0], osc2[0], \mix.kr(0));
				var lofreq = lopass * (2.pow( (5.0 * \mlopass.kr(0) * mod_env) + (2.5 * \llopass.kr(0) * lfo)));
				var hifreq = hipass * (2.pow( (5.0 * \mhipass.kr(0) * mod_env) + (2.5 * \lhipass.kr(0) * lfo)));
				var degrade = \degrade.kr(0.0);
				snd = Decimator.ar(snd, (48000.0 / (1.0 + (15.0 * degrade))), (16.0 - (12.0 * degrade)));
				snd = SVF.ar(snd, hifreq, (\hires.kr(0.0) + (\mhires.kr(0.0) * mod_env) + (\lhires.kr(0.0) * lfo)), lowpass:0, hiphpass:1);
				snd = SVF.ar(snd, lofreq, (\lores.kr(0.0) + (\mlores.kr(0.0) * mod_env) + (\llores.kr(0.0) * lfo)));
				snd = (snd * amp_env).dup;
				Out.ar(\out.kr(0), snd);
				Out.ar(\sendABus.kr(0), \sendA.kr(0)*snd);
				Out.ar(\sendBBus.kr(0), \sendB.kr(0)*snd);
			}).add;
			SynthDef(\soda_bitters_perc, { |out|
				var amp_env = Env.perc(\attack.kr(0.0015), \release(0.8), \amp.kr(0.5)).kr(2);
				var mod_env = Env.perc(\mattack.kr(0.0015), \mrelease(0.8)).kr(0);
				var lfo = LFTri.kr(\lfreq.kr(4.0), mul:Env.asr(\lfade.kr(0.0), 1, 10).kr(0));
				var note = \note.kr(69);
				var mpitch = \mpitch.kr(0.0);
				var lpitch = \lpitch.kr(0.0);
				var freq1 = (note + \pitch1.kr(0.0) + (1.2 * mpitch * mod_env) + (1.2 * lpitch * lfo)).midicps;
				var freq2 = (note + \pitch2.kr(0.0) + (1.2 * mpitch * mod_env) + (1.2 * lpitch * lfo)).midicps;
				var fm1 = SinOsc.ar(
					freq:(ratio1 * freq1),
					mul:(\index1.kr(0.0) + (2.0 * \mindex1.kr(0.0) * mod_env) + (2.0 * \lindex1.kr(0.0) * lfo)));
				var fm2 = SinOsc.ar(
					freq:(ratio2 * freq2),
					mul:(\index2.kr(0.0) + (2.0 * \mindex2.kr(0.0) * mod_env) + (2.0 * \lindex2.kr(0.0) * lfo)));
				var pw1 = \width1.kr(0.5) + (0.5 * \mdwidth1.kr(0.0) * mod_env) + (0.5 * \lwidth1.kr(0.0) * lfo);
				var pw2 = \width2.kr(0.5) + (0.5 * \mdwidth2.kr(0.0) * mod_env) + (0.5 * \lwidth2.kr(0.0) * lfo);
				var sync = \sync.kr(0.0);
				var osc1 = \tri1.kr(1.0) * TrianglePTR.ar(freq:freq1, phase:fm1, width:pw1)
				+ \pulse1.kr(0.0) * PulsePTR.ar(freq:freq1, phase:fm1, width:pw1);
				var osc2 = \tri2.kr(1.0) * TrianglePTR.ar(freq:freq2, phase: fm2, sync:sync * osc1[1], width:pw2)
				+ \pulse2.kr(0.0) * PulsePTR.ar(freq:freq2, phase:fm2, sync:sync * osc1[1], width:pw2);
				var snd = LinXFade2.ar(osc1[0], osc2[0], \mix.kr(0));
				var lofreq = \lopass.kr(22000) * (2.pow( (5.0 * \mlopass.kr(0) * mod_env) + (2.5 * \llopass.kr(0) * lfo)));
				var hifreq = \hipass.kr(10) * (2.pow( (5.0 * \mhipass.kr(0) * mod_env) + (2.5 * \lhipass.kr(0) * lfo)));
				var degrade = \degrade.kr(0.0);
				snd = Decimator.ar(snd, (48000.0 / (1.0 + (15.0 * degrade))), (16.0 - (12.0 * degrade)));
				snd = SVF.ar(snd, hifreq, (\hires.kr(0.0) + (\mhires.kr(0.0) * mod_env) + (\lhires.kr(0.0) * lfo)), lowpass:0, hiphpass:1);
				snd = SVF.ar(snd, lofreq, (\lores.kr(0.0) + (\mlores.kr(0.0) * mod_env) + (\llores.kr(0.0) * lfo)));
				snd = (snd * amp_env).dup;
				Out.ar(out, snd);
				Out.ar(\sendABus.kr(0), \sendA.kr(0)*snd);
				Out.ar(\sendBBus.kr(0), \sendB.kr(0)*snd);
			}).add;
			OSCFunc.new({ |msg, time, addr, recvPort|
				var args = [
					[
						\note, \amp, \attack, \release, \mattack, \mrelease,
						\lfreq, \lfade, \pitch1, \pitch2, \mpitch, \lpitch,
						\index1, \mindex1, \lindex1, \index2, \mindex2, \lindex2,
						\width1, \mwidth1, \lwidth1, \width2, \mwidth2, \lwidth2,
						\sync, \tri1, \pulse1, \tri2, \pulse2, \mix,
						\lopass, \mlopass, \llopass, \lores, \mlores, \llores,
						\hipass, \mhipass, \lhipass, \hires, \mhires, \lhires,
						\degrade, \sendA, \sendB
					]
					msg[1..]
				].lace;
				Synth.new(
					\soda_bitters_perc,
					args ++ [
						\sendABus, (~sendA ? Server.default.outputBus),
						\sendBBus, (~sendB ? Server.default.outputBus)]);
			}, "/soda/bitters/perc");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var args = [
					[
						\amp, \attack, \decay, \sustain, \release,
						\mattack, \mdecay, \msustain, \mrelease,
						\lfreq, \lfade, \pitch1, \pitch2, \mpitch, \lpitch,
						\index1, \mindex1, \lindex1, \index2, \mindex2, \lindex2,
						\width1, \mwidth1, \lwidth1, \width2, \mwidth2, \lwidth2,
						\sync, \tri1, \pulse1, \tri2, \pulse2, \mix,
						\lopass, \mlopass, \llopass, \lores, \mlores, \llores,
						\hipass, \mhipass, \lhipass, \hires, \mhires, \lhires,
						\degrade, \sendA, \sendB
					]
					msg[3..]
				].lace;
				var syn;
				(Routine {
					while({thisThread.clock.seconds - lastAction < 0.003}, {
						(0.001).yield;
					});
					syn = Synth.new(
						\soda_bitters,
						args ++ [
							\gate, 1,
							\sendABus, (~sendA ? Server.default.outputBus),
							\sendBBus, (~sendB ? Server.default.outputBus)],
						target: groups[voice]);
					lastAction = thisThread.clock.seconds;
					syn.onFree({
						var currentNote;
						currentNote = inverse[voice][syn];
						inverse[voice].removeAt(syn);
						if (notes[voice][currentNote] === syn, {
							notes[voice].removeAt(currentNote);
						});
					});
					if (notes[voice].includesKey(note), {
						var toEnd = notes[voice][note];
						toend.set
					});
					notes[voice].put(note, syn);
					inverse[voice].put(syn, note);
				}).play;
			}, "/soda/bitters/note_on");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var key = msg[3].asString.asSymbol;
				var val = msg[4].asFloat;
				if (notes[voice].includesKey(note), {
					var syn = notes[voice][note];
					syn.set(key, val);
				});
			}, "/soda/bitters/note_simple_mod");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var new_note = msg[3].asInteger;
				var args = [[
					\amp, \attack, \decay, \sustain, \release,
					\mattack, \mdecay, \msustain, \mrelease,
					\lfreq, \lfade, \pitch1, \pitch2, \mpitch, \lpitch,
					\index1, \mindex1, \lindex1, \index2, \mindex2, \lindex2,
					\width1, \mwidth1, \lwidth1, \width2, \mwidth2, \lwidth2,
					\sync, \tri1, \pulse1, \tri2, \pulse2, \mix,
					\lopass, \mlopass, \llopass, \lores, \mlores, \llores,
					\hipass, \mhipass, \lhipass, \hires, \mhires, \lhires,
					\degrade, \sendA, \sendB],
					msg[4..]
				].lace;
				if (notes[voice].includesKey(note), {
					var syn = notes[voice][note];
					syn.set(\gate, 1.0, *args);
					notes[voice].put(new_note, syn);
					if(note != new_note, {
						notes[voice].removeAt(note);
						inverse[voice].put(syn, new_note)
					});
				}, {
					// if condition is false; let's add a new note.
					var syn = Synth.new(\soda_bitters,
						args ++ [\sendABus, (~sendA ? Server.default.outputBus),
							\sendBBus, (~sendB ? Server.default.outputBus)
						], target: groups[voice]);
					syn.onFree({
						var currentNote;
						currentNote = inverse[voice][syn];
						inverse[voice].removeAt(syn);
						if (notes[voice][currentNote] === syn, {
							notes[voice].removeAt(currentNote);
						});
					});
					notes[voice].put(new_note, syn);
					inverse[voice].put(syn, new_note);
				});
			}, "/soda/bitters/note_mod");
			OSCFunc.new({ |msg, time, addr, recvPort|
				notes.keysValuesDo { |voice, active|
					active.keysValuesDo { |note, syn|
						syn.set(\gate, 0);
						active.removeAt(note);
						inverse.removeAt(syn);
					};
				};
			}, "/soda/bitters/stop_all");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				if (notes[voice].includesKey(note), {
					// var current = notes[voice][note];
					notes[voice][note].set(\gate, 0);
				});
			}, "/soda/bitters/note_off");
		}
	}
}

Soda_Turns {
	classvar <notes, <inverse, <groups, <lastAction;
	
	*initClass {
		notes = 6.collect { Dictionary.new };
		inverse = 6.collect { IdentityDictionary.new };
		lastAction = 0;
		
		Startup.add {
			(Routine.new {
				10.yield;
				Server.default.sync;
				groups = 6.collect { Group.new };
				"SODA TURNS ME CRAZY".postln;
			}).play;
			SynthDef(\turns, { |out|
				var ampgate = \amp_gate.kr(1);
				var env = Env.adsr(\amp_attack.kr(0.1), \amp_decay.kr(0.3), \amp_sustain.kr(0.7), \amp_release.kr(0.2)).kr(2, ampgate);
				var modenv = Env.adsr(\mod_attack.kr(0.1), \mod_decay.kr(0.3), \mod_sustain.kr(0.7), \mod_release.kr(0.2)).kr(0, \mod_gate.kr(0));
				var lfo = LFTri.kr(\lfo_freq.kr(1), mul:Env.asr(\lfo_fade.kr(0), 1, 10).kr(0, ampgate));
				var amp_lfo = lfo.madd(0.05, 0.05) * \lfo_amp_mod.kr(0);
				var note = \note.kr(69);
				var pitch_mod = (1.2 * \lfo_pitch_mod.kr(0) * lfo) + (1.2 * modenv * \env_pitch_mod.kr(0));
				var pitch_sq = (note + \detune_square.kr(0) + pitch_mod).midicps;
				var width_sq = \width_square.kr(0.5) + (0.5 * \lfo_square_width_mod.kr(0) * lfo) + (\env_square_width_mod.kr(0) * modenv);
				var index = \fm_index.kr(0) + (2 * \env_index_mod.kr(0) * modenv) + (20 * \lfo_index_mod.kr(0) * amp_lfo);
				var sq = PulsePTR.ar(freq:pitch_sq, width:width_sq, phase:SinOsc.ar(pitch_sq * \fm_numerator.kr(1) / \fm_denominator.kr(1), mul:index))[0];
				var pitch_form = (note + \detune_formant.kr(0) + pitch_mod).midicps;
				var width_form = \width_formant.kr(0.5) + (0.5 * \lfo_formant_width_mod.kr(0) * lfo) + (\env_formant_width_mod.kr(0) * modenv);
				var form_form = pitch_form * ((2 ** \formant.kr(0)) + (sq * \square_formant_mod.kr(0)) + (lfo * \lfo_formant_mod.kr(0)) + (modenv * \env_formant_mod.kr(0)));
				var form = SineShaper.ar(FormantTriPTR.ar(pitch_form, form_form, width_form) * (\formant_amp.kr(0.5) + (sq * \square_formant_amp_mod.kr(0))), 0.5, 2);
				var snd = (env + amp_lfo) * (form + (\square_amp.kr(0.5) * sq));
				var hifreq = (2 ** (modenv * 5 * \env_highpass_mod.kr(0)) + (lfo * \lfo_highpass_mod.kr(0))) * \highpass_freq.kr(50);
				var lofreq = (2 ** (modenv * 5 * \env_lowpass_mod.kr(0)) + (lfo * \lfo_lowpass_mod.kr(0))) * \lowpass_freq.kr(15000);
				snd = SVF.ar(snd, hifreq, \highpass_resonance.kr(0), lowpass:0, highpass:1);
				snd = SVF.ar(snd, lofreq, \lowpass_resonance.kr(0));
				snd = Pan2.ar(snd * 0.5 * \amp.kr(0.5), \pan.kr(0));
				Out.ar(out, snd);
				Out.ar(\sendABus.kr(0), \sendA.kr(0)*snd);
				Out.ar(\sendBBus.kr(0), \sendB.kr(0)*snd);
			}).add;
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var args = [
					[
						\mod_gate, \amp, \pan
						\amp_attack, \amp_decay, \amp_sustain, \amp_release,
						\mod_attack, \mod_decay, \mod_sustain, \mod_release,
						\lfo_freq, \lfo_fade, \lfo_amp_mod,
						\lfo_pitch_mod, \env_pitch_mod,
						\detune_square, \width_square, \lfo_square_width_mod, \env_square_width_mod,
						\detune_formant, \width_formant,
						\lfo_formant_width_mod, \env_formant_width_mod, \square_formant_mod, \lfo_formant_mod, \env_formant_mod,
						\fm_numerator, \fm_denominator,
						\fm_index, \env_index_mod, \lfo_index_mod,
						\square_amp
						\formant_amp, \square_formant_amp_mod,
						\env_lowpass_mod, \lfo_lowpass_mod, \lowpass_freq, \lowpass_resonance,
						\env_highpass_mod, \lfo_highpass_mod, \highpass_freq, \highpass_resonance,
						\sendA, \sendB
					]
					msg[3..]
				].lace;
				var syn;
				(Routine {
					while({thisThread.clock.seconds - lastAction < 0.003}, {
						(0.001).yield;
					});
					syn = Synth.new(
						\soda_bitters,
						args ++ [
							\gate, 1,
							\sendABus, (~sendA ? Server.default.outputBus),
							\sendBBus, (~sendB ? Server.default.outputBus)],
						target: groups[voice]);
					lastAction = thisThread.clock.seconds;
					syn.onFree({
						var currentNote;
						currentNote = inverse[voice][syn];
						inverse[voice].removeAt(syn);
						if (notes[voice][currentNote] === syn, {
							notes[voice].removeAt(currentNote);
						});
					});
					if (notes[voice].includesKey(note), {
						var toEnd = notes[voice][note];
						toend.set
					});
					notes[voice].put(note, syn);
					inverse[voice].put(syn, note);
				}).play;
			}, "/soda/turns/note_on");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var key = msg[3].asString.asSymbol;
				var val = msg[4].asFloat;
				if (notes[voice].includesKey(note), {
					var syn = notes[voice][note];
					syn.set(key, val);
				});
			}, "/soda/turns/note_simple_mod");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				var new_note = msg[3].asInteger;
				var args = [[
					\amp_gate, \mod_gate, \amp, \pan
					\amp_attack, \amp_decay, \amp_sustain, \amp_release,
					\mod_attack, \mod_decay, \mod_sustain, \mod_release,
					\lfo_freq, \lfo_fade, \lfo_amp_mod,
					\lfo_pitch_mod, \env_pitch_mod,
					\detune_square, \width_square, \lfo_square_width_mod, \env_square_width_mod,
					\detune_formant, \width_formant,
					\lfo_formant_width_mod, \env_formant_width_mod, \square_formant_mod, \lfo_formant_mod, \env_formant_mod,
					\fm_numerator, \fm_denominator,
					\fm_index, \env_index_mod, \lfo_index_mod,
					\square_amp
					\formant_amp, \square_formant_amp_mod,
					\env_lowpass_mod, \lfo_lowpass_mod, \lowpass_freq, \lowpass_resonance,
					\env_highpass_mod, \lfo_highpass_mod, \highpass_freq, \highpass_resonance,
					\sendA, \sendB],
					msg[4..]
				].lace;
				if (notes[voice].includesKey(note), {
					var syn = notes[voice][note];
					syn.set(\gate, 1.0, *args);
					notes[voice].put(new_note, syn);
					if(note != new_note, {
						notes[voice].removeAt(note);
						inverse[voice].put(syn, new_note)
					});
				}, {
					// if condition is false; let's add a new note.
					var syn = Synth.new(\soda_bitters,
						args ++ [\sendABus, (~sendA ? Server.default.outputBus),
							\sendBBus, (~sendB ? Server.default.outputBus)
						], target: groups[voice]);
					syn.onFree({
						var currentNote;
						currentNote = inverse[voice][syn];
						inverse[voice].removeAt(syn);
						if (notes[voice][currentNote] === syn, {
							notes[voice].removeAt(currentNote);
						});
					});
					notes[voice].put(new_note, syn);
					inverse[voice].put(syn, new_note);
				});
			}, "/soda/turns/note_mod");
			OSCFunc.new({ |msg, time, addr, recvPort|
				notes.keysValuesDo { |voice, active|
					active.keysValuesDo { |note, syn|
						syn.set(\gate, 0);
						active.removeAt(note);
						inverse.removeAt(syn);
					};
				};
			}, "/soda/turns/stop_all");
			OSCFunc.new({ |msg, time, addr, recvPort|
				var voice = msg[1].asInteger;
				var note = msg[2].asInteger;
				if (notes[voice].includesKey(note), {
					// var current = notes[voice][note];
					notes[voice][note].set(\gate, 0);
				});
			}, "/soda/turns/note_off");
		}
	}
}