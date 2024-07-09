/*
    Copyright (C) 2023 Vis LLC - All Rights Reserved

    This program is free software : you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https ://www.gnu.org/licenses/>.
*/

/*
    ISTAR - Insanely Simple Transfer And Reporting
*/

package com.sdtk.api;

#if(!EXCLUDE_APIS && python)
@:expose
@:nativeGen
class TortoiseTTSAPI extends API {
    private static var _instance : TortoiseTTSAPI;

    private function new() {
        super("TortoiseTTS");
    }

    public static function instance() : TortoiseTTSAPI {
        if (_instance == null) {
            _instance = new TortoiseTTSAPI();
        }
        return _instance;
    }

    public function convert(callback : String->Dynamic->Void, query : String, voice : String) : Void {
        // TODO - Add process id of some kind to file name.
        function generateAudioSegment(text : String, audio : Array<String>, tts : Dynamic, voiceSamples : Dynamic, conditioningLatents : Dynamic) : Void {
            python.Syntax.code("import torchaudio");
            var temp : String = python.lib.Tempfile.gettempdir() + "/SDTK-TTS-" + Std.string(audio.length) + ".mp3";
            audio.push(temp);
            var pcm_audio : Dynamic = python.Syntax.code("{0}.tts_with_preset({1}, voice_samples={2}, conditioning_latents={3})", tts, text, voiceSamples, conditioningLatents);
            python.Syntax.code("torchaudio.save({0}, {1}.squeeze(0).cpu(), 24000)", temp, pcm_audio);
        }

        function generateAudio(audio : Array<String>, query : String, voice : String) : Void {
            var r = ~/[.;,:'"\(\)\[\]\n]+/g;
            var text : Array<String> = r.split(query);
            query = null;
            var voiceSamples : Dynamic = null;
            var conditioningLatents : Dynamic = null;
            python.Syntax.code("from tortoise.api import TextToSpeech, MODELS_DIR");
            python.Syntax.code("from tortoise.utils.audio import load_voice");
            python.Syntax.code("[{0}, {1}] = load_voice({2})", voiceSamples, conditioningLatents, voice);
            var tts : Dynamic = python.Syntax.code("TextToSpeech()");
            for (t in text) {
                generateAudioSegment(t, audio, tts, voiceSamples, conditioningLatents);
            }
        }

        function mergeAudio(audio : Array<String>) : Dynamic {
            python.Syntax.code("import torch");
            python.Syntax.code("import torchaudio");
            var audioData : Dynamic = null;

            for (file in audio) {
                var fileData : Dynamic = null;
                python.Syntax.code("{0}, _ = torchaudio.load({1})", fileData, file);
                if (audioData == null) {
                    audioData = fileData;
                } else {
                    audioData = python.Syntax.code("torch.cat(({0}, {1}), dim=1)", audioData, fileData);
                }
            }

            for (file in audio) {
                sys.FileSystem.deleteFile(file);
            }

            return audioData;
        }

        var audio : Array<String> = new Array<String>();
        generateAudio(audio, query, voice);
        var result : Dynamic = mergeAudio(audio);
        callback(query, result);
    }

    public function convertToFile(callback : String->String->Void, query : String, voice : String, file : String) : Void {
        convert(function (query : String, result : Dynamic) : Void {
            python.Syntax.code("import torchaudio");
            python.Syntax.code("torchaudio.save({0}, {1}.cpu(), 24000)", file, result);
        }, query, voice);
    }
}
#end