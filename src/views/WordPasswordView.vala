/*
* Copyright (C) 2018  Christopher Nugent <awedeven+elementarydev@gmail.com>
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using App.Configs;
using App.Widgets;
using App;
using Gtk;

namespace App.Views {

    public class WordPasswordView : Grid {
    
        private CapitalizationMode capitalization_mode;
        private PasswordGenerator _password_generator;
    
        private App.Configs.Settings _settings;
        
        private Label _password_text;
        private Scale _password_length_slider;
        private RadioButton[] _radios;
        
        
        public WordPasswordView (PasswordGenerator password_generator) {
            _password_generator = password_generator;
           
            _settings = App.Configs.Settings.get_instance ();
           
            create_password_text ();
            create_password_length_slider ();
            create_radio ();
            create_button ();              
            
            apply_settings ();
        }
        
        private void create_password_text () {
            _password_text = new Label ("Password will be here");
            _password_text.selectable = true;
            _password_text.margin = 12;
            _password_text.wrap = true;
            _password_text.wrap_mode = Pango.WrapMode.CHAR;
            attach (_password_text, 0, 0);
        }
        
        private void create_password_length_slider () {
            _password_length_slider = new Scale.with_range (Orientation.HORIZONTAL, 1, 8, 1);
            _password_length_slider.set_value (4);
            _password_length_slider.hexpand = true;
            _password_length_slider.margin = 12;
            
            _password_length_slider.value_changed.connect (() => {
                _settings.word_length = (int) _password_length_slider.get_value ();
            });
            
            _password_length_slider.add_mark (2, PositionType.TOP, "2");
            _password_length_slider.add_mark (4, PositionType.TOP, "4");
            _password_length_slider.add_mark (6, PositionType.TOP, "6");
            _password_length_slider.add_mark (8, PositionType.TOP, "8");
            
            attach (_password_length_slider, 0, 1);        
        }
            
        private void create_button () {
            var button_generate_password = new Button.with_label (_("Generate Password"));
            button_generate_password.margin = 12;
            button_generate_password.clicked.connect (() => {
                generate_password ();
            });
            attach (button_generate_password, 0, 4);       
            //_root_box.add (button_generate_password);
        }
        
        private void create_radio () {
             _radios = new RadioButton[3];
            
            var radio_box = new Box (Orientation.HORIZONTAL, 12);
            radio_box.halign = Align.CENTER;           
                           
            var camel_case_radio = new RadioButton.with_label_from_widget (null,
                    _("camelCase"));
            camel_case_radio.toggled.connect (() => {
                if (camel_case_radio.active) {
                    capitalization_mode = CapitalizationMode.CAMEL_CASE;
                    _settings.word_mode = 0;
                }
            });
            camel_case_radio.active = true;
            _radios[0] = camel_case_radio;
            radio_box.add (camel_case_radio);
            
            var title_case_radio = new RadioButton.with_label_from_widget (camel_case_radio,
                    _("TitleCase"));
            title_case_radio.toggled.connect (() => {
                if (title_case_radio.active) {
                    capitalization_mode = CapitalizationMode.TITLE_CASE;
                    _settings.word_mode = 1;
                }
            });
            _radios[1] = title_case_radio;
            radio_box.add (title_case_radio);
            
            var lower_case_radio = new RadioButton.with_label_from_widget (camel_case_radio,
                    _("lower_case"));
            lower_case_radio.toggled.connect (() => {
                if (lower_case_radio.active) {
                    capitalization_mode = CapitalizationMode.LOWER_CASE;
                    _settings.word_mode = 2;
                }
            });
            _radios[2] = lower_case_radio;
            radio_box.add (lower_case_radio);
            attach (radio_box, 0, 3);
        }
        
        private void generate_password () {
            var length = (int) _password_length_slider.get_value ();
            var generated_password = _password_generator.generate_password_from_words (length,
                    capitalization_mode);
            _password_text.label = generated_password;
            _settings.word_password = generated_password;
        }
        
        private void apply_settings () {
            _radios[_settings.word_mode].active = true;
            _password_length_slider.set_value (_settings.word_length);
            
            var password = _settings.word_password;
            if (password == "") {
                generate_password ();
            } else {
                _password_text.label = password;
            }
        }
    }
}
