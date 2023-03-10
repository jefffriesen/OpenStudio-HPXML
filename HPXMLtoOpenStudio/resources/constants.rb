# frozen_string_literal: true

class Constants
  # Numbers --------------------

  def self.AssumedInsideTemp
    return 73.5 # deg-F
  end

  def self.g
    return 32.174 # gravity (ft/s2)
  end

  def self.small
    return 1e-9
  end

  def self.NumDaysInMonths(year)
    num_days_in_months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    num_days_in_months[1] += 1 if Date.leap?(year)
    return num_days_in_months
  end

  def self.NumDaysInYear(year)
    num_days_in_months = NumDaysInMonths(year)
    num_days_in_year = num_days_in_months.sum
    return num_days_in_year
  end

  def self.NumHoursInYear(year)
    num_days_in_year = NumDaysInYear(year)
    num_hours_in_year = num_days_in_year * 24
    return num_hours_in_year
  end

  # Strings --------------------

  def self.AirFilm
    return 'AirFilm'
  end

  def self.ERIVersions
    return ['2014', '2014A', '2014AE', '2014AEG', '2019', '2019A',
            '2019AB', '2019ABC', '2019ABCD']
  end

  def self.FacadeFront
    return 'front'
  end

  def self.FacadeBack
    return 'back'
  end

  def self.FacadeLeft
    return 'left'
  end

  def self.FacadeRight
    return 'right'
  end

  def self.FluidWater
    return 'water'
  end

  def self.FluidPropyleneGlycol
    return 'propylene-glycol'
  end

  def self.FluidEthyleneGlycol
    return 'ethylene-glycol'
  end

  def self.FossilFuels
    return [HPXML::FuelTypeNaturalGas,
            HPXML::FuelTypePropane,
            HPXML::FuelTypeOil,
            HPXML::FuelTypeCoal,
            HPXML::FuelTypeWoodCord,
            HPXML::FuelTypeWoodPellets]
  end

  def self.IECCZones
    return ['1A', '1B', '1C', '2A', '2B', '2C', '3A', '3B', '3C',
            '4A', '4B', '4C', '5A', '5B', '5C', '6A', '6B', '6C', '7', '8']
  end

  def self.IsDuctLoadForReport
    return __method__.to_s
  end

  def self.ObjectNameAirflow
    return 'airflow'
  end

  def self.ObjectNameAirSourceHeatPump
    return 'air source heat pump'
  end

  def self.ObjectNameBackupHeatingCoil
    return 'backup htg coil'
  end

  def self.ObjectNameBoiler
    return 'boiler'
  end

  def self.ObjectNameBoilerPilotLight(boiler_name)
    return "#{boiler_name} pilot light"
  end

  def self.ObjectNameCeilingFan
    return 'ceiling fan'
  end

  def self.ObjectNameCentralAirConditioner
    return 'central ac'
  end

  def self.ObjectNameCentralAirConditionerAndFurnace
    return 'central ac and furnace'
  end

  def self.ObjectNameClothesWasher
    return 'clothes washer'
  end

  def self.ObjectNameClothesDryer
    return 'clothes dryer'
  end

  def self.ObjectNameClothesDryerExhaust
    return 'clothes dryer exhaust'
  end

  def self.ObjectNameComponentLoadsProgram
    return 'component loads program'
  end

  def self.ObjectNameCookingRange
    return 'cooking range'
  end

  def self.ObjectNameCoolingSeason
    return 'cooling season'
  end

  def self.ObjectNameCoolingSetpoint
    return 'cooling setpoint'
  end

  def self.ObjectNameDehumidifier
    return 'dehumidifier'
  end

  def self.ObjectNameDesuperheater(water_heater_name)
    return "#{water_heater_name} Desuperheater"
  end

  def self.ObjectNameDishwasher
    return 'dishwasher'
  end

  def self.ObjectNameDistributionWaste
    return 'dhw distribution waste'
  end

  def self.ObjectNameDucts
    return 'ducts'
  end

  def self.ObjectNameElectricBaseboard
    return 'baseboard'
  end

  def self.ObjectNameERVHRV
    return 'erv or hrv'
  end

  def self.ObjectNameEvaporativeCooler
    return 'evap cooler'
  end

  def self.ObjectNameExteriorLighting
    return 'exterior lighting'
  end

  def self.ObjectNameFanPumpDisaggregateCool(fan_or_pump_name = '')
    return "#{fan_or_pump_name} clg disaggregate"
  end

  def self.ObjectNameFanPumpDisaggregatePrimaryHeat(fan_or_pump_name = '')
    return "#{fan_or_pump_name} htg primary disaggregate"
  end

  def self.ObjectNameFanPumpDisaggregateBackupHeat(fan_or_pump_name = '')
    return "#{fan_or_pump_name} htg backup disaggregate"
  end

  def self.ObjectNameFixtures
    return 'dhw fixtures'
  end

  def self.ObjectNameFreezer
    return 'freezer'
  end

  def self.ObjectNameFurnace
    return 'furnace'
  end

  def self.ObjectNamePTACHeating
    return 'ptac heating'
  end

  def self.ObjectNameRoomACHeating
    return 'room ac heating'
  end

  def self.ObjectNameFurniture
    return 'furniture'
  end

  def self.ObjectNameGarageLighting
    return 'garage lighting'
  end

  def self.ObjectNameGroundSourceHeatPump
    return 'ground source heat pump'
  end

  def self.ObjectNameGSHPSharedPump()
    return 'gshp shared loop pump'
  end

  def self.ObjectNameHeatingSeason
    return 'heating season'
  end

  def self.ObjectNameHeatingSetpoint
    return 'heating setpoint'
  end

  def self.ObjectNameHotWaterRecircPump
    return 'dhw recirc pump'
  end

  def self.ObjectNameIdealAirSystem
    return 'ideal air system'
  end

  def self.ObjectNameInfiltration
    return 'infil'
  end

  def self.ObjectNameInteriorLighting
    return 'interior lighting'
  end

  def self.ObjectNameLightingExteriorHoliday
    return 'exterior holiday lighting'
  end

  def self.ObjectNameMechanicalVentilation
    return 'mech vent'
  end

  def self.ObjectNameMechanicalVentilationPrecooling
    return 'mech vent precooling'
  end

  def self.ObjectNameMechanicalVentilationPreheating
    return 'mech vent preheating'
  end

  def self.ObjectNameMechanicalVentilationHouseFan
    return 'mech vent house fan'
  end

  def self.ObjectNameMechanicalVentilationHouseFanCFIS
    return 'mech vent house fan cfis'
  end

  def self.ObjectNameMechanicalVentilationHouseFanCFISSupplFan
    return 'mech vent house fan cfis suppl'
  end

  def self.ObjectNameMechanicalVentilationBathFan
    return 'mech vent bath fan'
  end

  def self.ObjectNameMechanicalVentilationRangeFan
    return 'mech vent range fan'
  end

  def self.ObjectNameMiniSplitAirConditioner
    return 'mini split air conditioner'
  end

  def self.ObjectNameMiniSplitHeatPump
    return 'mini split heat pump'
  end

  def self.ObjectNamePTHP
    return 'packaged terminal heat pump'
  end

  def self.ObjectNameRoomHP
    return 'room ac with reverse cycle'
  end

  def self.ObjectNamePTAC
    return 'packaged terminal air conditioner'
  end

  def self.ObjectNameMiscGrill
    return 'misc grill'
  end

  def self.ObjectNameMiscLighting
    return 'misc lighting'
  end

  def self.ObjectNameMiscFireplace
    return 'misc fireplace'
  end

  def self.ObjectNameMiscPoolHeater
    return 'misc pool heater'
  end

  def self.ObjectNameMiscPoolPump
    return 'misc pool pump'
  end

  def self.ObjectNameMiscHotTubHeater
    return 'misc hot tub heater'
  end

  def self.ObjectNameMiscHotTubPump
    return 'misc hot tub pump'
  end

  def self.ObjectNameMiscPlugLoads
    return 'misc plug loads'
  end

  def self.ObjectNameMiscTelevision
    return 'misc tv'
  end

  def self.ObjectNameMiscElectricVehicleCharging
    return 'misc electric vehicle charging'
  end

  def self.ObjectNameMiscWellPump
    return 'misc well pump'
  end

  def self.ObjectNameNaturalVentilation
    return 'natural vent'
  end

  def self.ObjectNameNeighbors
    return 'neighbors'
  end

  def self.ObjectNameOccupants
    return 'occupants'
  end

  def self.ObjectNameOverhangs
    return 'overhangs'
  end

  def self.ObjectNamePlantLoopDHW
    return 'dhw loop'
  end

  def self.ObjectNamePlantLoopSHW
    return 'solar hot water loop'
  end

  def self.ObjectNameRefrigerator
    return 'fridge'
  end

  def self.ObjectNameRelativeHumiditySetpoint
    return 'rh setpoint'
  end

  def self.ObjectNameRoomAirConditioner
    return 'room ac'
  end

  def self.ObjectNameSkylightShade
    return 'skylight shade'
  end

  def self.ObjectNameSolarHotWater
    return 'solar hot water'
  end

  def self.ObjectNameTankHX
    return 'dhw source hx'
  end

  def self.ObjectNameTotalLoadsProgram
    return 'total loads program'
  end

  def self.ObjectNameUnitHeater
    return 'unit heater'
  end

  def self.ObjectNameUnmetHoursProgram
    return 'unmet hours program'
  end

  def self.ObjectNameWaterHeater
    return 'water heater'
  end

  def self.ObjectNameWaterLatent
    return 'water latent'
  end

  def self.ObjectNameWaterSensible
    return 'water sensible'
  end

  def self.ObjectNameWaterHeaterAdjustment(water_heater_name)
    return "#{water_heater_name} EC adjustment"
  end

  def self.ObjectNameBatteryLossesAdjustment(battery_name)
    return "#{battery_name} losses adjustment"
  end

  def self.ObjectNameWaterLoopHeatPump
    return 'water loop heat pump'
  end

  def self.ObjectNameWholeHouseFan
    return 'whole house fan'
  end

  def self.ObjectNameWindowShade
    return 'window shade'
  end

  def self.ScheduleTypeLimitsFraction
    return 'Fractional'
  end

  def self.ScheduleTypeLimitsOnOff
    return 'OnOff'
  end

  def self.ScheduleTypeLimitsTemperature
    return 'Temperature'
  end

  def self.StateCodesMap
    return { 'AK' => 'Alaska',
             'AL' => 'Alabama',
             'AR' => 'Arkansas',
             'AZ' => 'Arizona',
             'CA' => 'California',
             'CO' => 'Colorado',
             'CT' => 'Connecticut',
             'DC' => 'District of Columbia',
             'DE' => 'Delaware',
             'FL' => 'Florida',
             'GA' => 'Georgia',
             'HI' => 'Hawaii',
             'IA' => 'Iowa',
             'ID' => 'Idaho',
             'IL' => 'Illinois',
             'IN' => 'Indiana',
             'KS' => 'Kansas',
             'KY' => 'Kentucky',
             'LA' => 'Louisiana',
             'MA' => 'Massachusetts',
             'MD' => 'Maryland',
             'ME' => 'Maine',
             'MI' => 'Michigan',
             'MN' => 'Minnesota',
             'MO' => 'Missouri',
             'MS' => 'Mississippi',
             'MT' => 'Montana',
             'NC' => 'North Carolina',
             'ND' => 'North Dakota',
             'NE' => 'Nebraska',
             'NH' => 'New Hampshire',
             'NJ' => 'New Jersey',
             'NM' => 'New Mexico',
             'NV' => 'Nevada',
             'NY' => 'New York',
             'OH' => 'Ohio',
             'OK' => 'Oklahoma',
             'OR' => 'Oregon',
             'PA' => 'Pennsylvania',
             'RI' => 'Rhode Island',
             'SC' => 'South Carolina',
             'SD' => 'South Dakota',
             'TN' => 'Tennessee',
             'TX' => 'Texas',
             'UT' => 'Utah',
             'VA' => 'Virginia',
             'VT' => 'Vermont',
             'WA' => 'Washington',
             'WI' => 'Wisconsin',
             'WV' => 'West Virginia',
             'WY' => 'Wyoming' }
  end
end
