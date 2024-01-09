a = arduino('COM12','Mega2560','Libraries','Ultrasonic')

x = 0;
y = 0;
zx = 0;
zy = 0;

GreenTimer = 30;
YellowTimer = 4.5;

crossSTGreen = 'D53'; %Green Light for Cross Street
SwitchOutputPin =  'A1';
sensorPin = 'A0'
SwitchPin = 'D40'
ultrasonicObj =  ultrasonic(a,'D4','D24');
writeDigitalPin(a,SwitchPin, 1);

%Assign digital pins for other lights
mainSTRed = 'D41';
mainSTYellow = 'D43';
mainSTGreen = 'D45';
crossSTRed = 'D49';
crossSTYellow = 'D51';
crossSTGreen = 'D53';
pedSignal1 = 'D37';
pedSignal2 = 'D35';

%Start with Main Street green light on and Cross St red light on. All
%others off
writeDigitalPin(a,mainSTRed,0);
writeDigitalPin(a,mainSTYellow,0);
writeDigitalPin(a,mainSTGreen,1);
writeDigitalPin(a,crossSTRed,1);
writeDigitalPin(a,crossSTYellow,0);
writeDigitalPin(a,crossSTGreen,0);

while(1)
    ultrasonicDistance =  readDistance(ultrasonicObj); 
    ForceSensor = readVoltage(a,sensorPin);
    Button = readVoltage(a,SwitchOutputPin);
    if ultrasonicDistance < .06 || ForceSensor >= 4.7 %Detect car at intersection with ultrasonic sensor or bike on force sensor
        x = 1;
    elseif Button == 5 %Detect crosswalk button pressed
        y = 1;
    end
    display(ultrasonicDistance) %Show reading for ultrasonic sensor
    display(ForceSensor) %Show reading for force sensor
    if x == 1 && zy == 0 %Checks condition for ultrasonic or force sensor activation
        if zx == 0 %Checks if timer already started
            tic %Starts timer
            zx = 1 %Prevents loop from starting timer over
        end
        
        if toc < 3 %Main St traffic light from green to yellow
            writeDigitalPin(a,mainSTGreen,0);
            writeDigitalPin(a,mainSTYellow,1);
            
        elseif toc < 8 %Main St traffic light from yellow to red and Cross St red to green
            writeDigitalPin(a,mainSTYellow,0);
            writeDigitalPin(a,mainSTRed,1);
            writeDigitalPin(a,crossSTGreen,1);
            writeDigitalPin(a,crossSTRed,0)
           
        elseif toc < 10 %Cross St traffic light from green to yellow
            writeDigitalPin(a,crossSTGreen,0);
            writeDigitalPin(a,crossSTYellow,1);
            
        elseif toc < 12 %Cross St traffic light from yellow to red and Main St light from red to green
            writeDigitalPin(a,crossSTYellow,0);
            writeDigitalPin(a,crossSTRed,1);
            writeDigitalPin(a,mainSTGreen,1);
            writeDigitalPin(a,mainSTRed,0);
            x = 0; %remove activation for ultrasonic and force sensor
            zx = 0; %remove check to prevent loop from starting timer over
        end
    end

    if y == 1 && zx == 0 %Detect crosswalk button activation
        if zy == 0 %Checks if timer already started
            tic %Starts timer
            zy = 1; %prevents loop from starting timer over
        end

        if toc < 3 %Main St traffic light from green to yellow
            writeDigitalPin(a,mainSTGreen,0);
            writeDigitalPin(a,mainSTYellow,1);
        elseif toc < 6 %Main St traffic light from yellow to red and turns crosswalk lights on
            writeDigitalPin(a,mainSTYellow,0);
            writeDigitalPin(a,mainSTRed,1);
            writeDigitalPin(a,pedSignal1,1);
            writeDigitalPin(a,pedSignal2,1);
            

        elseif toc < 10 %Crosswalk lights off and Main St lights from red to green
            writeDigitalPin(a,pedSignal1,0);
            writeDigitalPin(a,pedSignal2,0);
            writeDigitalPin(a,mainSTGreen,1);
            writeDigitalPin(a,mainSTRed,0);
            y = 0; %remove activaton for Crosswalk button
            zy = 0; %remove check to prevent loop from starting timer over
        end

    end
        

   
    
end