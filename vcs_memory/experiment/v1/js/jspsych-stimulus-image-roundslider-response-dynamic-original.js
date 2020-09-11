/**
 * jspsych-stimulus-image-roundslider-response-dynamic
 * a jspsych plugin for free response survey questions
 *
 * Josh de Leeuw
 *
 * documentation: docs.jspsych.org
 *
 */


jsPsych.plugins['stimulus-image-roundslider-response-dynamic'] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('image-slider-response', 'stimulus', 'image');

  plugin.info = {
    name: 'image-slider-response',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Stimulus',
        default: undefined,
        description: 'The image to be displayed'
      },
      slider_stimulus: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Slider Stimulus',
        default: undefined,
        description: 'The image to be adjusted with the slider'
      },
      stimulus_base: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Stimulus Base Name',
        default: undefined,
        description: 'The core name base for the img to be displayed'
      },
      stimulus_height: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Image height',
        default: null,
        description: 'Set the image height in pixels'
      },
      stimulus_width: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Image width',
        default: null,
        description: 'Set the image width in pixels'
      },
      slider_stimulus_height: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Slider Image height',
        default: null,
        description: 'Set the slider image height in pixels'
      },
      slider_stimulus_width: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Slider Image width',
        default: null,
        description: 'Set the slider image width in pixels'
      },
      maintain_aspect_ratio: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Maintain aspect ratio',
        default: true,
        description: 'Maintain the aspect ratio after setting width or height'
      },
      min: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Min slider',
        default: 0,
        description: 'Sets the minimum value of the slider.'
      },
      max: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Max slider',
        default: 100,
        description: 'Sets the maximum value of the slider',
      },
      start: {
				type: jsPsych.plugins.parameterType.INT,
				pretty_name: 'Slider starting value',
				default: 50,
				description: 'Sets the starting value of the slider',
			},
      step: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Step',
        default: 1,
        description: 'Sets the step of the slider'
      },
      labels: {
        type: jsPsych.plugins.parameterType.HTML_STRING,
        pretty_name:'Labels',
        default: [],
        array: true,
        description: 'Labels of the slider.',
      },
      slider_radius: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name:'Slider radius',
        default: null,
        description: 'Radius of the slider in pixels.'
      },
      button_label: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Button label',
        default:  'Continue',
        array: false,
        description: 'Label of the button to advance.'
      },
      require_movement: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Require movement',
        default: false,
        description: 'If true, the participant will have to move the slider before continuing.'
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: 'Prompt',
        default: null,
        description: 'Any content here will be displayed below the slider.'
      },
      stimulus_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Stimulus duration',
        default: null,
        description: 'How long to hide the stimulus.'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: null,
        description: 'How long to show the trial.'
      },
      response_ends_trial: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Response ends trial',
        default: true,
        description: 'If true, trial will end when user makes a response.'
      },
	  no_slider: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Remove slider',
        default: false,
        description: 'If true, slider is removed.'
    },
	button_present: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: 'Whether a response button is available',
        default: true,
        description: 'If false, no response button available.'
    }
}
  }

  plugin.trial = function(display_element, trial) {

    var html = '<div id="jspsych-image-slider-response-wrapper" style="margin: 100px 0px;">';
    html += '<div id="jspsych-image-slider-response-stimulus">';
    html += '<img class="stimulus" id="stimulus_id" src="'+trial.stimulus+'" style="';
    if(trial.stimulus_height !== null){
      html += 'height:'+trial.stimulus_height+'px; '
      if(trial.stimulus_width == null && trial.maintain_aspect_ratio){
        html += 'width: auto; ';
      }
    }
    if(trial.stimulus_width !== null){
      html += 'width:'+trial.stimulus_width+'px; '
      if(trial.stimulus_height == null && trial.maintain_aspect_ratio){
        html += 'height: auto; ';
      }
    }
	html+='background-color: transparent; width:300px; height: 300px; border: 10px solid black; margin-left: 50px;float: left;'
	//html += '<div id="frame" style="background-color: transparent; width:300px; height: 300px;border: 10px solid black; margin-left: 50px;float: left;"></div>';
    html += '"></img>';
    html += '</div>';
	html += '<img class="slider_stimulus" id="slider_stimulus_id" src="'+trial.slider_stimulus+'" style="';
    if(trial.slider_stimulus_height !== null){
      html += 'height:'+trial.stimulus_height+'px; '
      if(trial.slider_stimulus_width == null && trial.maintain_aspect_ratio){
        html += 'width: auto; ';
      }
    }
    if(trial.slider_stimulus_width !== null){
      html += 'width:'+trial.slider_stimulus_width+'px; '
      if(trial.slider_stimulus_height == null && trial.maintain_aspect_ratio){
        html += 'height: auto; ';
      }
    }
    if(trial.no_slider){
      html += 'visibility:hidden; '
    }
    html += '"></img>';
	
	html+='<div id="slider"></div>';
	
	//old slider info
    // html += '<div class="jspsych-image-slider-response-container" style="position:relative; margin: 0 auto 3em auto; ';
    // if(trial.slider_width !== null){
    //   html += 'width:'+trial.slider_width+'px;';
    // }
    // html += '">';
    // html += '<input type="range" value="'+trial.start+'" min="'+trial.min+'" max="'+trial.max+'" step="'+trial.step+'" style="width: 100%;" id="jspsych-image-slider-response-response"></input>';
    // html += '<div>'
    // for(var j=0; j < trial.labels.length; j++){
    //   var width = 100/(trial.labels.length-1);
    //   var left_offset = (j * (100 /(trial.labels.length - 1))) - (width/2);
    //   html += '<div style="display: inline-block; position: absolute; left:'+left_offset+'%; text-align: center; width: '+width+'%;">';
    //   html += '<span style="text-align: center; font-size: 80%;">'+trial.labels[j]+'</span>';
    //   html += '</div>'
    // }
    // html += '</div>';
    // html += '</div>';
    // html += '</div>';

    if (trial.prompt !== null){
      //html += trial.prompt;
	  //html += '<p style="position: relative; top: 100px; left: -250px"' +trial.prompt+'</p>';
	  html += '<p style="clear: both;position: relative; top: -300px"' +trial.prompt+'</p>';
    }
	
	if (trial.no_slider) {
		slider_disabled = true;
		
	} else {
		slider_disabled = false;
	}
	
	if (trial.button_present) {
	    // add submit button
	    html += '<button id="jspsych-image-slider-response-next" class="jspsych-btn" '+ (trial.require_movement ? "disabled" : "") + ' style="clear: both; position: relative;top: -300px">'+trial.button_label+'</button>';

    
	    //html += '<button id="jspsych-image-slider-response-next" class="jspsych-btn" '+ (trial.require_movement ? "disabled" : "") + ' style="position: relative; top: 100px; left:-250px">'+trial.button_label+'</button>';
		//html += '<button id="jspsych-image-slider-response-next" class="jspsych-btn" '+ (trial.require_movement ? "disabled" : "") + ' style="position: absolute; top: 550px">'+trial.button_label+'</button>';
	
	};
	
    display_element.innerHTML = html;

    var response = {
      rt: null,
      response: null
    };
	
	$("#slider").roundSlider(
		{
			max: 359,
			min: 0,
			sliderType: "default",
			editableTooltip: false,
			radius: trial.slider_radius,
			width: "5",
			startValue: trial.start,
			handleShape: "round",
			handleSize: "+25",
			showTooltip: false,
			disabled: slider_disabled,
			borderColor: "black",
			width: 0,
			borderWidth: 300,
			//tooltipFormat: "tooltipVal",
			drag: function (args) {
				if (args.value == 0) {
					image_name = "images/VCS_".concat("360",".png");
				} else {
					image_name = "images/VCS_".concat(args.value,".png");
				}
				//console.log(image_name);
				document.getElementById("slider_stimulus_id").src=image_name;
				if (trial.require_movement) {
					display_element.querySelector('#jspsych-image-slider-response-next').disabled = false;
				};
			}
		}
	);
	
	
		//     display_element.querySelector('#jspsych-image-slider-response-response').addEventListener('input', function(){
		// cur_value = display_element.querySelector('#jspsych-image-slider-response-response').value;
		//
		// 	  display_element.querySelector('.stimulus').src = trial.stimulus_base+cur_value.toString()+'.png';
		// 	  display_element.querySelector('#jspsych-image-slider-response-next').disabled = false;
		//     })
	
		//     display_element.querySelector('#jspsych-image-slider-response-response').addEventListener('change', function(){
		// cur_value = display_element.querySelector('#jspsych-image-slider-response-response').value;
		//
		// 	  display_element.querySelector('.stimulus').src = trial.stimulus_base+cur_value.toString()+'.png';
		//     })

    // if(trial.require_movement){
    //   display_element.querySelector('#jspsych-image-slider-response-response').addEventListener('change', function(){
    //     display_element.querySelector('#jspsych-image-slider-response-next').disabled = false;
    //   })
    // }
	
	//add click function for button, if available
	if (trial.button_present) {

    display_element.querySelector('#jspsych-image-slider-response-next').addEventListener('click', function(obj) {
      // measure response time
      var endTime = performance.now();
      response.rt = endTime - startTime;
      //response.response = display_element.querySelector('#jspsych-image-slider-response-response').value;
	  response.response = $("#slider").data("roundSlider").getValue();
	  console.log($("#slider").data("roundSlider").getValue());

      if(trial.response_ends_trial){
        end_trial();
      } else {
        display_element.querySelector('#jspsych-image-slider-response-next').disabled = true;
      }

    });
	
};

    function end_trial(){

      jsPsych.pluginAPI.clearAllTimeouts();

      // save data
      var trialdata = {
        "rt": response.rt,
        "response": response.response,
		  "stimulus": trial.stimulus
      };

      display_element.innerHTML = '';

      // next trial
      jsPsych.finishTrial(trialdata);
    }

    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        display_element.querySelector('#jspsych-image-slider-response-stimulus').style.visibility = 'hidden';
      }, trial.stimulus_duration);
    }

    // end trial if trial_duration is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }

    var startTime = performance.now();
  };

  return plugin;
})();
