local musicutil = require("musicutil")
local mod = require("core/mods")
local status, matrix = pcall(require "matrix/lib/matrix")
if not status then
  matrix = nil
end

local extensions = "/home/we/.local/share/SuperCollider/Extensions/"
local has_files = {
  os.execute('test -n "$(find ' .. extensions .. ' -name TrianglePTR.sc)"'),
  os.execute('test -n "$(find ' .. extensions .. ' -name PulsePTR.sc)"'),
  os.execute('test -n "$(find ' .. extensions .. ' -name FormantTriPTR.sc)"')
}
local function needs_restart_hook()
  local flag = false
  local files = {
    { "TrianglePTR.sc",   "TrianglePTR_scsynth.so" },
    { "PulsePTR.sc",      "PulsePTR_scsynth.so" },
    { "FormantTriPTR.sc", "FormantTriPTR_scsynth.so" },
  }
  local folder = {
    "TrianglePTR/",
    "PulsePTR/",
    "FormantTriPTR/"
  }
  for index, test in ipairs(has_files) do
    if not test then
      flag = true
      print("soda: installing UGen")
      for _, file in pairs(files[index]) do
        if not util.file_exists(extensions .. folder[index] .. file) then
          util.os_capture("mkdir -p " .. extensions .. folder[index])
          util.os_capture("cp " .. _path.code .. "soda/ignore/" .. file .. " " .. extensions .. folder[index] .. file)
          print("installed " .. file)
        end
      end
    end
  end
  if flag then
    print("PLEASE RESTART")
  else
    print("soda found UGens")
  end
end

local bitters_note = {}

local function b(i, s)
  return "soda_bitters_" .. "_" .. i
end

local function t(i, s)
  return "soda_turns_" .. "_" .. i
end

local style_opts = { "perc", "poly" }

local function add_bitters_params(i)
  params:add_group(b(i, "group"), "bitters voice " .. i, 45)
  params:hide(b(i, "group"))
  params:add_option(b(i, "style"), "style", style_opts, 1)
  params:set_action(b(i, "style"), function(s)
    if s == 1 then
      params:show(b(i, "trigger"))
      params:hide(b(i, "gate"))
      params:hide(b(i, "d"))
      params:hide(b(i, "mdecay"))
      params:hide(b(i, "s"))
      params:hide(b(i, "msustain"))
    elseif s > 1 then
      params:hide(b(i, "trigger"))
      params:show(b(i, "gate"))
      params:show(b(i, "d"))
      params:show(b(i, "mdecay"))
      params:show(b(i, "s"))
      params:show(b(i, "msustain"))
    end
    _menu.rebuild_params()
    osc.send({ "localhost", "57120" }, "/soda/bitters/stop_all", {})
  end)
  if matrix then
    matrix:defer_bang(b(i, "style"))
  end
  params:add_trigger(b(i, "trigger"), "trigger")
  params:add_binary(b(i, "gate"), "gate", "momentary", 0)
  params:add_number(b(i, "note"), "note", 12, 127, 69, function(p)
    return musicutil.note_num_to_name(p:get(), true)
  end)
  params:add {
    type = "control",
    id = b(i, "amp"),
    name = "volume",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
  }
  params:add {
    type = "control",
    id = b(i, "degrade"),
    name = "degrade",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type = "control",
    id = b(i, "mix"),
    name = "osc mix",
    controlspec = controlspec.new(-1, 1, 'lin', 0.01, 0)
  }
  params:add {
    type = "control",
    id = b(i, "mpitch"),
    name = "env > pitch",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type = "control",
    id = b(i, "lpitch"),
    name = "lfo > pitch",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  for j = 1, 2 do
    params:add_separator(b(i, "osc_" .. j))
    params:add {
      type = "control",
      id = b(i, "octave_" .. j),
      name = "octave",
      controlspec = controlspec.new(-2, 1, 'lin', 1, 0)
    }
    params:add {
      type = "control",
      id = b(i, "coarse_" .. j),
      name = "coarse",
      controlspec = controlspec.new(-12, 12, 'lin', 1, 0),
    }
    params:add {
      type = "control",
      id = bi(i, "fine_" .. j),
      name = "fine",
      controlspec = controlspec.new(-100, 100, 'lin', 1, 0),
    }
    params:add {
      type    = "option",
      id      = b(i, "wave_" .. j),
      name    = "waveform",
      options = { "triangle", "square" },
      default = j,
    }
    params:add {
      type        = "control",
      id          = b(i, "width_" .. j),
      name        = "width",
      controlspec = controlspec.new(0, 1, 'lin', 0.01, 0.5),
    }
    params:add {
      type        = "control",
      id          = b(i, "mwidth_" .. j),
      name        = "env > width",
      controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
    }
    params:add {
      type        = "control",
      id          = b(i, "lwidth_" .. j),
      name        = "lfo > width",
      controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
    }
    params:add {
      type        = "control",
      id          = b(i, "numerator_" .. j),
      name        = "fm numerator",
      controlspec = controlspec.new(1, 30, 'lin', 1, 1),
    }
    params:add {
      type        = "control",
      id          = b(i, "denominator_" .. j),
      name        = "fm denominator",
      controlspec = controlspec.new(1, 30, 'lin', 1, 1),
    }
    params:add {
      type        = "control",
      id          = b(i, "index_" .. j),
      name        = "fm index",
      controlspec = controlspec.new(0, 5, 'lin', 0.01, 0),
    }
    params:add {
      type        = "control",
      id          = b(i, "mindex_" .. j),
      name        = "env > index",
      controlspec = controlspec.UNIPOLAR,
    }
    params:add {
      type        = "control",
      id          = b(i, "lindex_" .. j),
      name        = "lfo > index",
      controlspec = controlspec.UNIPOLAR,
    }
  end
  params:add {
    type    = "option",
    id      = b(i, "sync"),
    name    = "sync",
    options = { "off", "on" },
  }
  params:add_group("highpass", 6)
  params:add {
    type        = "control",
    id          = b(i, "hipass"),
    name        = "cutoff",
    controlspec = controlspec.new(0.01, 20000, 'exp', 0.01, 10),
  }
  params:add {
    type        = "control",
    id          = b(i, "mhipass"),
    name        = "env > cutoff",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "lhipass"),
    name        = "lfo > cutoff",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "hires"),
    name        = "resonance",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "mhires"),
    name        = "env > res",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "lhires"),
    name        = "lfo > res",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add_separator(b(i, "lowpass"), "lowpass")
  params:add {
    type        = "control",
    id          = b(i, "lopass"),
    name        = "cutoff",
    controlspec = controlspec.new(0.01, 20000, 'exp', 0.01, 20000),
  }
  params:add {
    type        = "control",
    id          = b(i, "mlopass"),
    name        = "env > cutoff",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "llopass"),
    name        = "lfo > cutoff",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "lores"),
    name        = "resonance",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "mlores"),
    name        = "env > res",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add {
    type        = "control",
    id          = b(i, "llores"),
    name        = "lfo > res",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 0),
  }
  params:add_separator(b(i, "amp_env"), "amp env", 4)
  params:add {
    type        = "control",
    id          = b(i, "a"),
    name        = "attack",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.0015),
  }
  params:add {
    type        = "control",
    id          = b(i, "d"),
    name        = "decay",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
  }
  params:add {
    type        = "control",
    id          = b(i, "s"),
    name        = "sustain",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
  }
  params:add {
    type        = "control",
    id          = b(i, "r"),
    name        = "release",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
  }
  params:add_separator(b(i, "mod_env"), "mod env", 4)
  params:add {
    type        = "control",
    id          = b(i, "mattack"),
    name        = "attack",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.0015),
  }
  params:add {
    type        = "control",
    id          = b(i, "mdecay"),
    name        = "decay",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0.8),
  }
  params:add {
    type        = "control",
    id          = b(i, "msustain"),
    name        = "sustain",
    controlspec = controlspec.new(0, 1, 'lin', 0.01, 1),
  }
  params:add {
    type        = "control",
    id          = b(i, "mrelease"),
    name        = "release",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, .131),
  }
  params:add {
    type        = "control",
    id          = b(i, "lfreq"),
    name        = "lfo frequency",
    controlspec = controlspec.new(0.001, 10, 'exp', 0.01, 4, "hz"),
  }
  params:add {
    type        = "control",
    id          = b(i, "lfade"),
    name        = "lfo fade in",
    controlspec = controlspec.new(0.01, 10, 'exp', 0.01, 0),
  }
  params:add {
    type = "control",
    id = b(i, "send_a"),
    name = "send a",
    controlspec = controlspec.UNIPOLAR
  }
  params:add {
    type = "control",
    id = b(i, "send_b"),
    name = "send b",
    controlspec = controlspec.UNIPOLAR
  }
  params:set_action(b(i, "trigger"), function()
    osc.send({ "localhost", "57120" }, "/soda/bitters/perc", {
      params:get(b(i, "note")),
      params:get(b(i, "amp")),
      params:get(b(i, "a")),
      params:get(b(i, "r")),
      params:get(b(i, "mattack")),
      params:get(b(i, "mrelease")),
      params:get(b(i, "lfreq")),
      params:get(b(i, "lfade")),
      params:get(b(i, "octave_1")) + params:get(b(i, "coarse_1")) + 0.01 * params:get(b(i, "fine_1")),
      params:get(b(i, "octave_2")) + params:get(b(i, "coarse_2")) + 0.01 * params:get(b(i, "fine_2")),
      params:get(b(i, "mpitch")),
      params:get(b(i, "lpitch")),
      params:get(b(i, "index_1")),
      params:get(b(i, "mindex_1")),
      params:get(b(i, "lindex_1")),
      params:get(b(i, "index_2")),
      params:get(b(i, "mindex_2")),
      params:get(b(i, "lindex_2")),
      params:get(b(i, "width_1")),
      params:get(b(i, "mwidth_1")),
      params:get(b(i, "lwidth_1")),
      params:get(b(i, "width_2")),
      params:get(b(i, "mwidth_2")),
      params:get(b(i, "lwidth_2")),
      params:get(b(i, "sync")),
      params:get(b(i, "wave_1")) == 1 and 1 or 0,
      params:get(b(i, "wave_1")) == 1 and 0 or 1,
      params:get(b(i, "wave_2")) == 1 and 1 or 0,
      params:get(b(i, "wave_2")) == 1 and 0 or 1,
      params:get(b(i, "mix")),
      params:get(b(i, "lopass")),
      params:get(b(i, "mlopass")),
      params:get(b(i, "llopass")),
      params:get(b(i, "lores")),
      params:get(b(i, "mlores")),
      params:get(b(i, "llores")),
      params:get(b(i, "hipass")),
      params:get(b(i, "mhipass")),
      params:get(b(i, "lhipass")),
      params:get(b(i, "lores")),
      params:get(b(i, "mlores")),
      params:get(b(i, "llores")),
      params:get(b(i, "degrade")),
      params:get(b(i, "send_a")),
      params:get(b(i, "send_b")),
    })
  end)
  params:set_action(b(i, "gate"), function(g)
    local note = params:get(b(i, "note"))
    if g > 0 then
      if bitters_note[i] then
        osc.send({ "localhost", "57120" }, "/soda/bitters/note_off", {
          i - 1,
          bitters_note[i]
        })
      end
      bitters_note[i] = note
      osc.send({ "localhost", "57120" }, "/soda/bitters/note_on", {
        i - 1,
        params:get(b(i, "note")),
        params:get(b(i, "amp")),
        params:get(b(i, "a")),
        params:get(b(i, "d")),
        params:get(b(i, "s")),
        params:get(b(i, "r")),
        params:get(b(i, "mattack")),
        params:get(b(i, "mdecay")),
        params:get(b(i, "msustain")),
        params:get(b(i, "mrelease")),
        params:get(b(i, "lfreq")),
        params:get(b(i, "lfade")),
        params:get(b(i, "octave_1")) + params:get(b(i, "coarse_1")) + 0.01 * params:get(b(i, "fine_1")),
        params:get(b(i, "octave_2")) + params:get(b(i, "coarse_2")) + 0.01 * params:get(b(i, "fine_2")),
        params:get(b(i, "mpitch")),
        params:get(b(i, "lpitch")),
        params:get(b(i, "index_1")),
        params:get(b(i, "mindex_1")),
        params:get(b(i, "lindex_1")),
        params:get(b(i, "index_2")),
        params:get(b(i, "mindex_2")),
        params:get(b(i, "lindex_2")),
        params:get(b(i, "width_1")),
        params:get(b(i, "mwidth_1")),
        params:get(b(i, "lwidth_1")),
        params:get(b(i, "width_2")),
        params:get(b(i, "mwidth_2")),
        params:get(b(i, "lwidth_2")),
        params:get(b(i, "sync")),
        params:get(b(i, "wave_1")) == 1 and 1 or 0,
        params:get(b(i, "wave_1")) == 1 and 0 or 1,
        params:get(b(i, "wave_2")) == 1 and 1 or 0,
        params:get(b(i, "wave_2")) == 1 and 0 or 1,
        params:get(b(i, "mix")),
        params:get(b(i, "lopass")),
        params:get(b(i, "mlopass")),
        params:get(b(i, "llopass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "hipass")),
        params:get(b(i, "mhipass")),
        params:get(b(i, "lhipass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "degrade")),
        params:get(b(i, "send_a")),
        params:get(b(i, "send_b")),
      })
    else
      if bitters_note[i] then
        osc.send({ "localhost", "57120" }, "/soda/bitters/note_off", {
          i - 1,
          bitters_note[i]
        })
      end
    end
  end)
end

function add_bitters_player(i)
  local player = {}

  function player:active()
    if self.name then
      params:show(b(i, "group"))
      _menu.rebuild_params()
    end
  end

  function player:inactive()
    if self.name then
      params:hide(b(i, "group"))
      _menu.rebuild_params()
    end
  end

  function player:stop_all()
    osc.send({ "localhost", "57120" }, "/soda/bitters/stop_all", {})
  end

  function player:describe()
    return {
      name = "bitters " .. i,
      supports_bend = false,
      supports_slew = false,
      modulate_description = "timbre",
      note_mod_targets = {
        "amp",
        "lowpass",
        "highpass"
      }
    }
  end

  function player:modulate_note(note, key, value)
    if params:get(b(i, "style")) > 1 and note == self.current_note then
      local v = value
      if key == "amp" then
        v = value + params:get(b(i, key))
      elseif key == "lowpass" then
        v = value + params:get(b(i, "lopass"))
      elseif key == "highpass" then
        v = value + params:get(b(i, "hipass"))
      end
      osc.send({ "localhost", "57120" }, "/soda/bitters/note_simple_mod", {
        i - 1,
        note,
        key,
        v,
      })
    end
  end

  function player:note_on(note, vel, properties)
    if properties == nil then
      properties = {}
    end
    if params:get(b(i, "style")) == 1 then
      local prop_amp = properties.amp or 0
      local prop_lopass = properties.lowpass or 0
      local prop_hipass = properties.highpass or 0
      osc.send({ "localhost", "57120" }, "/soda/bitters/perc", {
        params:get(b(i, "note")),
        (params:get(b(i, "amp")) + prop_amp) * vel * vel,
        params:get(b(i, "a")),
        params:get(b(i, "r")),
        params:get(b(i, "mattack")),
        params:get(b(i, "mrelease")),
        params:get(b(i, "lfreq")),
        params:get(b(i, "lfade")),
        params:get(b(i, "octave_1")) + params:get(b(i, "coarse_1")) + 0.01 * params:get(b(i, "fine_1")),
        params:get(b(i, "octave_2")) + params:get(b(i, "coarse_2")) + 0.01 * params:get(b(i, "fine_2")),
        params:get(b(i, "mpitch")),
        params:get(b(i, "lpitch")),
        params:get(b(i, "index_1")),
        params:get(b(i, "mindex_1")),
        params:get(b(i, "lindex_1")),
        params:get(b(i, "index_2")),
        params:get(b(i, "mindex_2")),
        params:get(b(i, "lindex_2")),
        params:get(b(i, "width_1")),
        params:get(b(i, "mwidth_1")),
        params:get(b(i, "lwidth_1")),
        params:get(b(i, "width_2")),
        params:get(b(i, "mwidth_2")),
        params:get(b(i, "lwidth_2")),
        params:get(b(i, "sync")),
        params:get(b(i, "wave_1")) == 1 and 1 or 0,
        params:get(b(i, "wave_1")) == 1 and 0 or 1,
        params:get(b(i, "wave_2")) == 1 and 1 or 0,
        params:get(b(i, "wave_2")) == 1 and 0 or 1,
        params:get(b(i, "mix")),
        params:get(b(i, "lopass")) + prop_lopass,
        params:get(b(i, "mlopass")),
        params:get(b(i, "llopass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "hipass")) + prop_hipass,
        params:get(b(i, "mhipass")),
        params:get(b(i, "lhipass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "degrade")),
        params:get(b(i, "send_a")),
        params:get(b(i, "send_b")),
      })
    else
      osc.send({ "localhost", "57120" }, "/soda/bitters/note_on", {
        i - 1,
        params:get(b(i, "note")),
        params:get(b(i, "amp")),
        params:get(b(i, "a")),
        params:get(b(i, "d")),
        params:get(b(i, "s")),
        params:get(b(i, "r")),
        params:get(b(i, "mattack")),
        params:get(b(i, "mdecay")),
        params:get(b(i, "msustain")),
        params:get(b(i, "mrelease")),
        params:get(b(i, "lfreq")),
        params:get(b(i, "lfade")),
        params:get(b(i, "octave_1")) + params:get(b(i, "coarse_1")) + 0.01 * params:get(b(i, "fine_1")),
        params:get(b(i, "octave_2")) + params:get(b(i, "coarse_2")) + 0.01 * params:get(b(i, "fine_2")),
        params:get(b(i, "mpitch")),
        params:get(b(i, "lpitch")),
        params:get(b(i, "index_1")),
        params:get(b(i, "mindex_1")),
        params:get(b(i, "lindex_1")),
        params:get(b(i, "index_2")),
        params:get(b(i, "mindex_2")),
        params:get(b(i, "lindex_2")),
        params:get(b(i, "width_1")),
        params:get(b(i, "mwidth_1")),
        params:get(b(i, "lwidth_1")),
        params:get(b(i, "width_2")),
        params:get(b(i, "mwidth_2")),
        params:get(b(i, "lwidth_2")),
        params:get(b(i, "sync")),
        params:get(b(i, "wave_1")) == 1 and 1 or 0,
        params:get(b(i, "wave_1")) == 1 and 0 or 1,
        params:get(b(i, "wave_2")) == 1 and 1 or 0,
        params:get(b(i, "wave_2")) == 1 and 0 or 1,
        params:get(b(i, "mix")),
        params:get(b(i, "lopass")),
        params:get(b(i, "mlopass")),
        params:get(b(i, "llopass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "hipass")),
        params:get(b(i, "mhipass")),
        params:get(b(i, "lhipass")),
        params:get(b(i, "lores")),
        params:get(b(i, "mlores")),
        params:get(b(i, "llores")),
        params:get(b(i, "degrade")),
        params:get(b(i, "send_a")),
        params:get(b(i, "send_b")),
      })
    end
  end

  function player:note_off(note)
    osc.send({ "localhost", "57120" }, "/soda/bitters/note_off", {
      i - 1, note
    })
  end

  function player:add_params()
    add_bitters_params(i)
  end

  if note_players == nil then
    note_players = {}
  end
  note_players["bitters " .. i] = player
end

local function pre_init()
  for i = 1, 4 do
    add_bitters_player(i)
  end
end

mod.hook.register("script_pre_init", "soda pre init", pre_init)
mod.hook.register("system_post_startup", "soda post startup", needs_restart_hook)
