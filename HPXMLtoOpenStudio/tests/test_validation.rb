# frozen_string_literal: true

require_relative '../resources/minitest_helper'
require 'openstudio'
require 'openstudio/ruleset/ShowRunnerOutput'
require 'minitest/autorun'
require 'fileutils'
require_relative '../measure.rb'
require_relative '../resources/util.rb'
require 'schematron-nokogiri'

class HPXMLtoOpenStudioSchematronTest < MiniTest::Test
  def before_setup
    @root_path = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
    @tmp_output_path = File.join(@root_path, 'workflow', 'sample_files', 'tmp_output')
    FileUtils.mkdir_p(@tmp_output_path)
    @tmp_hpxml_path = File.join(@tmp_output_path, 'tmp.xml')
  end
  
  def after_teardown
    FileUtils.rm_rf(@tmp_output_path)
  end

  def get_hpxml_file_name(key)
    if key.include? '/HPXML/Building/BuildingDetails/Appliances/Dehumidifier'
      return 'base-appliances-dehumidifier.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors'
      return 'base-misc-neighbor-shading.xml'
    elsif key == '/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor[ExteriorAdjacentTo[text()="other housing unit"]]/extension/OtherSpaceAboveOrBelow'
      return 'base-enclosure-other-housing-unit.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Enclosure/Foundations' # FIXME: Review this!
      return 'base-foundation-vented-crawlspace.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Enclosure/Attics' # FIXME: Review this!
      return 'base-atticroof-vented.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Lighting/CeilingFan'
      return 'base-misc-ceiling-fans.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl'
      return 'base-hvac-programmable-thermostat.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other="DSE"]]'
      return 'base-hvac-dse.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]'
      return 'base-hvac-room-ac-only.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="evaporative cooler"]'
      return 'base-hvac-evap-cooler-furnace-gas.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="mini-split"]'
      return 'base-hvac-mini-split-heat-pump-ducted.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump'
      return 'base-hvac-air-to-air-heat-pump-1-speed.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]'
      return 'base-mechvent-balanced.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="heat recovery ventilator"]'
      return 'base-mechvent-hrv.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="energy recovery ventilator"]'
      return 'base-mechvent-erv.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="central fan integrated supply"]'
      return 'base-mechvent-cfis.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]'
      return 'base-misc-whole-house-fan.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]' or
      key.include? '/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]'
      return 'base-mechvent-bath-kitchen-fans.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs'
      return 'base-enclosure-overhangs.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight'
      return 'base-enclosure-skylights.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]'
      return 'base-dhw-tankless-electric.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]'
      return 'base-dhw-tank-heat-pump.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]'
      return 'base-dhw-indirect.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with tankless coil"]/RelatedHVACSystem'
      return 'base-dhw-combi-tankless.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater="true"]'
      return 'base-dhw-desuperheater.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation'
      return 'base-dhw-recirc-timer.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery'
      return 'base-dhw-dwhr.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[SolarFraction]'
      return 'base-dhw-solar-fraction.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem' or
      key.include? '/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]'
      return 'base-dhw-solar-direct-flat-plate.xml'
    elsif key.include? '/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem'
      return 'base-pv.xml'
    else
      return 'base.xml'
    end
  end

  def test_valid_sample_files
    sample_files_dir = File.absolute_path(File.join(@root_path, 'workflow', 'sample_files'))
    hpxmls = []
    Dir["#{sample_files_dir}/*.xml"].sort.each do |xml|
      hpxmls << File.absolute_path(xml)
    end
    hpxmls.each do |hpxml|
      _test_schematron_validation(hpxml)
    end
  end

  def test_invalid_files_schematron_validation
    # Test for 'required' elements
    expected_error_msgs = { 
      ['/HPXML/XMLTransactionHeaderInformation/XMLType'] => "element 'XMLType' is REQUIRED",
      ['/HPXML/XMLTransactionHeaderInformation/XMLGeneratedBy'] => "element 'XMLGeneratedBy' is REQUIRED",
      ['/HPXML/XMLTransactionHeaderInformation/CreatedDateAndTime'] => "element 'CreatedDateAndTime' is REQUIRED",
      ['/HPXML/XMLTransactionHeaderInformation/Transaction'] => "element 'Transaction' is REQUIRED",
      ['/HPXML/Building'] => "element 'Building' is REQUIRED",
      ['/HPXML/Building/BuildingID'] => "element 'Building/BuildingID' is REQUIRED",
      ['/HPXML/Building/ProjectStatus/EventType'] => "element 'Building/ProjectStatus/EventType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction'] => "element 'BuildingConstruction' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation'] => "element 'WeatherStation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/HousePressure'] => "Air leakage must be provided in one of three ways: (a) nACH (natural air changes per hour), (b) ACH50 (air changes per hour at 50Pa), or (c) CFM50 (cubic feet per minute at 50Pa)",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/BuildingAirLeakage/UnitofMeasure'] => "Air leakage must be provided in one of three ways: (a) nACH (natural air changes per hour), (b) ACH50 (air changes per hour at 50Pa), or (c) CFM50 (cubic feet per minute at 50Pa)",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall'] => "the number of element 'Walls/Wall' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofConditionedFloors'] => "element 'NumberofConditionedFloors' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofConditionedFloorsAboveGrade'] => "element 'NumberofConditionedFloorsAboveGrade' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofBedrooms'] => "element 'NumberofBedrooms' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/ConditionedFloorArea'] => "element 'ConditionedFloorArea' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/ConditionedBuildingVolume'] => "either element 'ConditionedBuildingVolume' or element 'AverageCeilingHeight' must be provided",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding'] => "element 'NeighborBuilding' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Azimuth'] => "element 'Azimuth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Distance'] => "element 'Distance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC/Year'] => "element 'Year' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC/ClimateZone'] => "element 'ClimateZone' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/Name'] => "element 'Name' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/WMO'] => "either element 'WMO' or element 'extension/EPWFilePath' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()="ACH" or text()="CFM"]]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()="ACH" or text()="CFM"]]/BuildingAirLeakage/AirLeakage'] => "element 'BuildingAirLeakage/AirLeakage' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/SolarAbsorptance'] => "element 'SolarAbsorptance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Emittance'] => "element 'Emittance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Pitch'] => "element 'Pitch' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/RadiantBarrier'] => "element 'RadiantBarrier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Insulation/SystemIdentifier'] => "element 'Insulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Insulation/AssemblyEffectiveRValue'] => "element 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/ExteriorAdjacentTo'] => "element 'ExteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/WallType/WoodStud'] => "element 'WallType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/SolarAbsorptance'] => "element 'SolarAbsorptance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Emittance'] => "element 'Emittance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Insulation/SystemIdentifier'] => "element 'Insulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Insulation/AssemblyEffectiveRValue'] => "element 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/ExteriorAdjacentTo'] => "element 'ExteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/SolarAbsorptance'] => "element 'SolarAbsorptance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Emittance'] => "element 'Emittance' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Insulation/SystemIdentifier'] => "element 'Insulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Insulation/AssemblyEffectiveRValue'] => "element 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/ExteriorAdjacentTo'] => "element 'ExteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Height'] => "element 'Height' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Thickness'] => "element 'Thickness' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/DepthBelowGrade'] => "element 'DepthBelowGrade' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/SystemIdentifier'] => "element 'Insulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]'] => "element 'Insulation/Layer[InstallationType='continuous - interior']' or 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]'] => "element 'Insulation/Layer[InstallationType='continuous - exterior']' or 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/NominalRValue'] => "element 'NominalRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/extension/DistanceToTopOfInsulation'] => "element 'extension/DistanceToTopOfInsulation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/extension/DistanceToBottomOfInsulation'] => "element 'extension/DistanceToBottomOfInsulation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/NominalRValue'] => "element 'NominalRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/extension/DistanceToTopOfInsulation'] => "element 'extension/DistanceToTopOfInsulation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/extension/DistanceToBottomOfInsulation'] => "element 'extension/DistanceToBottomOfInsulation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/ExteriorAdjacentTo'] => "element 'ExteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Insulation/SystemIdentifier'] => "element 'Insulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Insulation/AssemblyEffectiveRValue'] => "element 'Insulation/AssemblyEffectiveRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor[ExteriorAdjacentTo[text()="other housing unit"]]/extension/OtherSpaceAboveOrBelow'] => "element 'extension/OtherSpaceAboveOrBelow' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/InteriorAdjacentTo'] => "element 'InteriorAdjacentTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/Thickness'] => "element 'Thickness' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/ExposedPerimeter'] => "element 'ExposedPerimeter' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulationDepth'] => "element 'PerimeterInsulationDepth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulationWidth'] => "element 'UnderSlabInsulationWidth' or 'UnderSlabInsulationSpansEntireSlab[text()=\"true\"]' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulation/SystemIdentifier'] => "element 'PerimeterInsulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulation/Layer[InstallationType="continuous"]/NominalRValue'] => "element 'PerimeterInsulation/Layer[InstallationType=\"continuous\"]/NominalRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulation/SystemIdentifier'] => "element 'UnderSlabInsulation/SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulation/Layer[InstallationType="continuous"]/NominalRValue'] => "element 'UnderSlabInsulation/Layer[InstallationType=\"continuous\"]/NominalRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/extension/CarpetFraction'] => "element 'extension/CarpetFraction' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/extension/CarpetRValue'] => "element 'extension/CarpetRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Azimuth'] => "element 'Azimuth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/UFactor'] => "element 'UFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/SHGC'] => "element 'SHGC' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/AttachedToWall'] => "element 'AttachedToWall' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/Depth'] => "element 'Depth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/DistanceToTopOfWindow'] => "element 'DistanceToTopOfWindow' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/DistanceToBottomOfWindow'] => "element 'DistanceToBottomOfWindow' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/Area'] => "element 'Area' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/Azimuth'] => "element 'Azimuth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/UFactor'] => "element 'UFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/SHGC'] => "element 'SHGC' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/AttachedToRoof'] => "element 'AttachedToRoof' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl'] => "element 'HVACControl' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/HeatingSystemType/Furnace'] => "element 'HeatingSystemType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/FractionHeatLoadServed'] => "element 'FractionHeatLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType/AirDistribution]'] => "the number of element '../../HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other='DSE']]' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/DistributionSystem'] => "element 'DistributionSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/HeatingSystemFuel'] => "element 'HeatingSystemFuel' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/AnnualHeatingEfficiency[Units="AFUE"]/Value'] => "element 'AnnualHeatingEfficiency[Units='AFUE']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingSystemType[text()="central air conditioner" or text()="room air conditioner" or text()="evaporative cooler"]'] => "element 'CoolingSystemType[text()='central air conditioner' or text()='room air conditioner' or text()='evaporative cooler']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingSystemFuel[text()="electricity"]'] => "element 'CoolingSystemFuel[text()='electricity']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/FractionCoolLoadServed'] => "element 'FractionCoolLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other="DSE"]]'] => "the number of element '../../HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other='DSE']]' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/DistributionSystem'] => "element 'DistributionSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/AnnualCoolingEfficiency[Units="SEER"]/Value'] => "element 'AnnualCoolingEfficiency[Units='SEER']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]/AnnualCoolingEfficiency[Units="EER"]/Value'] => "element 'AnnualCoolingEfficiency[Units='EER']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatPumpType'] => "element 'HeatPumpType[text()='air-to-air' or text()='mini-split' or text()='ground-to-air']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatPumpFuel'] => "element 'HeatPumpFuel[text()='electricity']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/FractionHeatLoadServed'] => "element 'FractionHeatLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/FractionCoolLoadServed'] => "element 'FractionCoolLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/DistributionSystem'] => "element 'DistributionSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/AnnualCoolingEfficiency[Units="SEER"]/Value'] => "element 'AnnualCoolingEfficiency[Units='SEER']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/AnnualHeatingEfficiency[Units="HSPF"]/Value'] => "element 'AnnualHeatingEfficiency[Units='HSPF']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetpointTempHeatingSeason'] => "element 'SetpointTempHeatingSeason' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetpointTempCoolingSeason'] => "element 'SetpointTempCoolingSeason' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]/TotalSetbackHoursperWeekHeating'] => "element 'TotalSetbackHoursperWeekHeating' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]/extension/SetbackStartHourHeating'] => "element 'extension/SetbackStartHourHeating' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]/TotalSetupHoursperWeekCooling'] => "element 'TotalSetupHoursperWeekCooling' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]/extension/SetupStartHourCooling'] => "element 'extension/SetupStartHourCooling' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution'] => "element 'DistributionSystemType/AirDistribution | DistributionSystemType/HydronicDistribution | DistributionSystemType[Other='DSE']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/ConditionedFloorAreaServed'] => "element '../../ConditionedFloorAreaServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/DuctLeakageMeasurement[DuctType="supply"]/DuctLeakage[(Units="CFM25" or Units="Percent") and TotalOrToOutside="to outside"]/Value'] => "element 'DuctLeakageMeasurement[DuctType='supply']/DuctLeakage[(Units='CFM25' or Units='Percent') and TotalOrToOutside='to outside']/Value' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other="DSE"]]/AnnualHeatingDistributionSystemEfficiency', '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other="DSE"]]/AnnualCoolingDistributionSystemEfficiency'] => "element 'AnnualHeatingDistributionSystemEfficiency | AnnualCoolingDistributionSystemEfficiency' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctInsulationRValue'] => "element 'DuctInsulationRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctSurfaceArea | DuctLocation[text()="living space" or text()="basement - conditioned" or text()="basement - unconditioned" or text()="crawlspace - vented" or text()="crawlspace - unvented" or text()="attic - vented" or text()="attic - unvented" or text()="garage" or text()="exterior wall" or text()="under slab" or text()="roof deck" or text()="outside" or text()="other housing unit" or text()="other heated space" or text()="other multifamily buffer space" or text()="other non-freezing space"]'] => "both element 'DuctSurfaceArea' and 'DuctLocation' MUST be either blank or provided",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/FanType[text()="energy recovery ventilator" or text()="heat recovery ventilator" or text()="exhaust only" or text()="supply only" or text()="balanced" or text()="central fan integrated supply"]'] => "element 'FanType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/TestedFlowRate'] => "element 'TestedFlowRate | RatedFlowRate' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/HoursInOperation'] => "element 'HoursInOperation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/FanPower'] => "element 'FanPower' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="heat recovery ventilator"]/SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency'] => "element 'SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="energy recovery ventilator"]/TotalRecoveryEfficiency | AdjustedTotalRecoveryEfficiency'] => "element 'TotalRecoveryEfficiency | AdjustedTotalRecoveryEfficiency' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="energy recovery ventilator"]/SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency'] => "element 'SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="central fan integrated supply"]/AttachedToHVACDistributionSystem'] => "element 'AttachedToHVACDistributionSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/RatedFlowRate'] => "element 'RatedFlowRate' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/FanPower'] => "element 'FanPower' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution'] => "element '../HotWaterDistribution' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture'] => "element '../WaterFixture' MUST be greater than or equal to 1",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/WaterHeaterType'] => "element 'WaterHeaterType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/FractionDHWLoadServed'] => "element 'FractionDHWLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/FuelType'] => "element 'FuelType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/EnergyFactor'] => "element 'EnergyFactor | UniformEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/FuelType'] => "element 'FuelType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/EnergyFactor'] => "element 'EnergyFactor | UniformEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/FuelType'] => "element 'FuelType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/TankVolume'] => "element 'TankVolume' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/EnergyFactor'] => "element 'EnergyFactor | UniformEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/RelatedHVACSystem'] => "element 'RelatedHVACSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/TankVolume'] => "element 'TankVolume' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with tankless coil"]/RelatedHVACSystem'] => "element 'RelatedHVACSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater="true"]/WaterHeaterType[text()="storage water heater" or text()="instantaneous water heater" or text()="heat pump water heater"]'] => "element 'WaterHeaterType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater="true"]/RelatedHVACSystem'] => "element 'RelatedHVACSystem' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Standard'] => "element 'SystemType/Standard | SystemType/Recirculation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/PipeInsulation/PipeRValue'] => "element 'PipeInsulation/PipeRValue' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/ControlType[text()="manual demand control" or text()="presence sensor demand control" or text()="temperature" or text()="timer" or text()="no control"]'] => "element 'ControlType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/FacilitiesConnected'] => "element 'FacilitiesConnected' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/EqualFlow'] => "element 'EqualFlow' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/Efficiency'] => "element 'Efficiency' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED", 
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/WaterFixtureType[text()="shower head" or text()="faucet"]'] => "element 'WaterFixtureType[text()='shower head' or text()='faucet']' is REQUIRED", 
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/LowFlow'] => "element 'LowFlow' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/SystemType[text()="hot water"]'] => "element 'SystemType[text()='hot water']' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/CollectorArea'] => "element 'CollectorArea | SolarFraction' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorLoopType[text()="liquid indirect" or text()="liquid direct" or text()="passive thermosyphon"]'] => "element 'CollectorLoopType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorType[text()="single glazing black" or text()="double glazing black" or text()="evacuated tube" or text()="integrated collector storage"]'] => "element 'CollectorType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorAzimuth'] => "element 'CollectorAzimuth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorTilt'] => "element 'CollectorTilt' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorRatedOpticalEfficiency'] => "element 'CollectorRatedOpticalEfficiency' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorRatedThermalLosses'] => "element 'CollectorRatedThermalLosses' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/ConnectedTo'] => "element 'ConnectedTo' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/Location[text()="ground" or text()="roof"]'] => "element 'Location' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ModuleType[text()="standard" or text()="premium" or text()="thin film"]'] => "element 'ModuleType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/Tracking[text()="fixed" or text()="1-axis" or text()="1-axis backtracked" or text()="2-axis"]'] => "element 'Tracking' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ArrayAzimuth'] => "element 'ArrayAzimuth' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ArrayTilt'] => "element 'ArrayTilt' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/MaxPowerOutput'] => "element 'MaxPowerOutput' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/IntegratedModifiedEnergyFactor'] => "element 'ModifiedEnergyFactor | IntegratedModifiedEnergyFactor | RatedAnnualkWh | LabelElectricRate | LabelGasRate | LabelAnnualGasCost | LabelUsage | Capacity' MUST be zero or equal to seven",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/FuelType[text()="natural gas" or text()="fuel oil" or text()="propane" or text()="electricity" or text()="wood" or text()="wood pellets"]'] => "element 'FuelType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/RatedAnnualkWh'] => "element 'RatedAnnualkWh | EnergyFactor | LabelElectricRate | LabelGasRate | LabelAnnualGasCost | LabelUsage | PlaceSettingCapacity' MUST be zero or equal to 6",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/Capacity'] => "element 'Capacity' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/EnergyFactor | IntegratedEnergyFactor'] => "element 'EnergyFactor | IntegratedEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/DehumidistatSetpoint'] => "element 'DehumidistatSetpoint' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/FractionDehumidificationLoadServed'] => "element 'FractionDehumidificationLoadServed' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/FuelType[text()="natural gas" or text()="fuel oil" or text()="propane" or text()="electricity" or text()="wood" or text()="wood pellets"]'] => "element 'FuelType' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]'] => "the number of element 'h:LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()='interior' or text()='exterior' or text()='garage']]' MUST be 9",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]/FractionofUnitsInLocation'] => "element 'FractionofUnitsInLocation' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/SystemIdentifier'] => "element 'SystemIdentifier' is REQUIRED",
    }
    
    expected_error_msgs.each do |keys, value|
      hpxml_name = get_hpxml_file_name(keys[0])
      hpxml = HPXML.new(hpxml_path: File.join(@root_path, 'workflow', 'sample_files', hpxml_name))
      hpxml_doc = hpxml.to_oga()
      keys.each do |key|
        XMLHelper.delete_element(hpxml_doc, key)
      end
      XMLHelper.write_file(hpxml_doc, @tmp_hpxml_path)
      _test_schematron_validation(@tmp_hpxml_path, value)
    end

    # Test for optional elements (i.e. zero_or_one, zero_or_two, etc.)
    expected_error_msgs_optional = {
      ['/HPXML/SoftwareInfo/extension/SimulationControl', nil] => "element 'extension/SimulationControl' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site', 'SiteType="suburban"'] => "element 'Site/SiteType' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/ShelterCoefficient', nil] => "element 'extension/ShelterCoefficient' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors', nil] => "element 'extension/Neighbors' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingOccupancy/NumberofResidents', nil] => "element 'BuildingOccupancy/NumberofResidents' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC', nil] => "element 'ClimateZoneIECC' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl', nil] => "element 'HVACControl' is OPTIONAL", # FIXME: Need to review this case
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForWholeBuildingVentilation="true"'] => "element 'VentilationFan[UsedForWholeBuildingVentilation='true']' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForLocalVentilation="true" and FanLocation="kitchen"'] => "element 'VentilationFan[UsedForLocalVentilation='true' and FanLocation='kitchen']' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForLocalVentilation="true" and FanLocation="bath"'] => "element 'VentilationFan[UsedForLocalVentilation='true' and FanLocation='bath']' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForSeasonalCoolingLoadReduction="true"'] => "element 'VentilationFan[UsedForSeasonalCoolingLoadReduction='true']' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem', nil] => "element 'SolarThermal/SolarThermalSystem' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher', nil] => "element 'ClothesWasher' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer', nil] => "element 'ClothesDryer' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher', nil] => "element 'Dishwasher' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator', nil] => "element 'Refrigerator' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier', nil] => "element 'Dehumidifier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange', nil] => "element 'CookingRange' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Lighting', nil] => "element 'Lighting' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan', nil] => "element 'Lighting/CeilingFan' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad', 'PlugLoadType="other"'] => "element 'PlugLoad[PlugLoadType='other']' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad', 'PlugLoadType="TV other"'] => "element 'PlugLoad[PlugLoadType='TV other']' is OPTIONAL",
      ['/HPXML/SoftwareInfo/extension/SimulationControl/Timestep', nil] => "element 'Timestep' is OPTIONAL",
      ['/HPXML/SoftwareInfo/extension/SimulationControl', 'BeginMonth=1'] => "Both 'BeginMonth' and 'BeginDayOfMonth' must be either blank or provided",
      ['/HPXML/SoftwareInfo/extension/SimulationControl', 'EndMonth=12'] => "Both 'EndMonth' and 'EndDayOfMonth' must be either blank or provided",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofBathrooms', nil] => "element 'NumberofBathrooms' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Height', nil] => "element 'Height' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/InfiltrationVolume', nil] => "element 'InfiltrationVolume' is OPTIONAL", # FIXME: Need to review parent Xpath
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Azimuth', nil] => "element 'Azimuth' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/Attics/Attic/VentilationRate/Value', nil] => "element 'Attic/VentilationRate/Value' is OPTIONAL", # FIXME: Review this!
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Azimuth', nil] => "element 'Azimuth' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Azimuth', nil] => "element 'Azimuth' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Azimuth', nil] => "element 'Azimuth' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/Foundations/Foundation/VentilationRate/Value', nil] => "element 'Crawlspace/VentilationRate/Value' is OPTIONAL", # FIXME: Review this!
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/InteriorShading/SummerShadingCoefficient', nil] => "element 'InteriorShading/SummerShadingCoefficient' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/InteriorShading/WinterShadingCoefficient', nil] => "element 'InteriorShading/WinterShadingCoefficient' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs', nil] => "element 'Overhangs' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/FractionOperable', nil] => "element 'FractionOperable' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/HeatingCapacity', nil] => "element 'HeatingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/ElectricAuxiliaryEnergy', nil] => "element 'ElectricAuxiliaryEnergy' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingCapacity', nil] => "element 'CoolingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/SensibleHeatFraction', nil] => "element 'SensibleHeatFraction' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]/CoolingCapacity', nil] => "element 'CoolingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]/SensibleHeatFraction', nil] => "element 'SensibleHeatFraction' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="evaporative cooler"]/DistributionSystem', nil] => "element 'DistributionSystem' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatingCapacity', nil] => "element 'HeatingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/CoolingCapacity', nil] => "element 'CoolingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/CoolingSensibleHeatFraction', nil] => "element 'CoolingSensibleHeatFraction' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/HeatingCapacity17F', nil] => "element 'HeatingCapacity17F' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="mini-split"]/DistributionSystem', nil] => "element 'DistributionSystem' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="mini-split"]/HeatingCapacity17F', nil] => "element 'HeatingCapacity17F' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]/BackupHeatingCapacity', nil] => "element 'BackupHeatingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]/BackupHeatingSwitchoverTemperature', nil] => "element 'BackupHeatingSwitchoverTemperature' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetbackTempHeatingSeason', nil] => "element 'SetbackTempHeatingSeason' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetupTempCoolingSeason', nil] => "element 'SetupTempCoolingSeason' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/extension/CeilingFanSetpointTempCoolingSeasonOffset', nil] => "element 'extension/CeilingFanSetpointTempCoolingSeasonOffset' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/DuctLeakageMeasurement[DuctType="return"]/DuctLeakage[(Units="CFM25" or Units="Percent") and TotalOrToOutside="to outside"]/Value', nil] => "element 'DuctLeakageMeasurement[DuctType='return']/DuctLeakage[(Units='CFM25' or Units='Percent') and TotalOrToOutside='to outside']/Value' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/NumberofReturnRegisters', nil] => "element 'NumberofReturnRegisters' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctSurfaceArea', nil] => "both element 'DuctSurfaceArea' and 'DuctLocation' MUST be either blank or provided",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/RatedFlowRate', nil] => "element 'RatedFlowRate' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/HoursInOperation', nil] => "element 'HoursInOperation' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/FanPower', nil] => "element 'FanPower' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/extension/StartHour', nil] => "element 'extension/StartHour' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/Quantity', nil] => "element 'Quantity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/RatedFlowRate', nil] => "element 'RatedFlowRate' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/HoursInOperation', nil] => "element 'HoursInOperation' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/FanPower', nil] => "element 'FanPower' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/extension/StartHour', nil] => "element 'extension/StartHour' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/HotWaterTemperature', nil] => "element 'HotWaterTemperature' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/UsesDesuperheater', nil] => "element 'UsesDesuperheater' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/TankVolume', nil] => "element 'TankVolume' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/HeatingCapacity', nil] => "element 'HeatingCapacity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/EnergyFactor', nil] => "element 'EnergyFactor | UniformEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/RecoveryEfficiency', nil] => "element 'RecoveryEfficiency' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "element 'WaterHeaterInsulation/Jacket/JacketRValue' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/PerformanceAdjustment', nil] => "element 'PerformanceAdjustment' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/EnergyFactor', nil] => "element 'EnergyFactor | UniformEnergyFactor' is REQUIRED",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "element 'WaterHeaterInsulation/Jacket/JacketRValue' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "element 'WaterHeaterInsulation/Jacket/JacketRValue' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/StandbyLoss', nil] => "element 'StandbyLoss' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery', nil] => "element 'DrainWaterHeatRecovery' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Standard/PipingLength', nil] => "element 'PipingLength' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/RecirculationPipingLoopLength', nil] => "element 'RecirculationPipingLoopLength' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/BranchPipingLoopLength', nil] => "element 'BranchPipingLoopLength' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/PumpPower', nil] => "element 'PumpPower' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/../extension/WaterFixturesUsageMultiplier', nil] => "element '../extension/WaterFixturesUsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/StorageVolume', nil] => "element 'StorageVolume' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[SolarFraction]/ConnectedTo', nil] => "element 'ConnectedTo' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/InverterEfficiency', nil] => "element 'InverterEfficiency' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/IntegratedModifiedEnergyFactor', nil] => "element 'ModifiedEnergyFactor | IntegratedModifiedEnergyFactor' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/CombinedEnergyFactor', nil] => "element 'EnergyFactor | CombinedEnergyFactor' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/RatedAnnualkWh', nil] => "element 'RatedAnnualkWh | EnergyFactor' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/WeekdayScheduleFractions', nil] => "element 'extension/WeekdayScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/WeekendScheduleFractions', nil] => "element 'extension/WeekendScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/MonthlyScheduleMultipliers', nil] => "element 'extension/MonthlyScheduleMultipliers' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/IsInduction', nil] => "element 'IsInduction' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/WeekdayScheduleFractions', nil] => "element 'extension/WeekdayScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/WeekendScheduleFractions', nil] => "element 'extension/WeekendScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/MonthlyScheduleMultipliers', nil] => "element 'extension/MonthlyScheduleMultipliers' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/../Oven/IsConvection', nil] => "element '../Oven/IsConvection' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Lighting/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/Airflow/Efficiency', nil] => "element 'Airflow[FanSpeed='medium']/Efficiency' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/Quantity', nil] => "element 'Quantity' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/Load/Value', nil] => "element 'Load[Units='kWh/year']/Value' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/FracSensible', nil] => "element 'extension/FracSensible' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/FracLatent', nil] => "element 'extension/FracLatent' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/WeekdayScheduleFractions', nil] => "element '../extension/WeekdayScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/WeekendScheduleFractions', nil] => "element '../extension/WeekendScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/MonthlyScheduleMultipliers', nil] => "element '../extension/MonthlyScheduleMultipliers' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/Load/Value', nil] => "element 'Load[Units='kWh/year']/Value' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/extension/UsageMultiplier', nil] => "element 'extension/UsageMultiplier' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/WeekdayScheduleFractions', nil] => "element '../extension/WeekdayScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/WeekendScheduleFractions', nil] => "element '../extension/WeekendScheduleFractions' is OPTIONAL",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/MonthlyScheduleMultipliers', nil] => "element '../extension/MonthlyScheduleMultipliers' is OPTIONAL",
    }

    expected_error_msgs_optional.each do |key, value|
      elements = key[0]
      child_elements_with_values = key[1]
      hpxml_name = get_hpxml_file_name(elements)
      hpxml = HPXML.new(hpxml_path: File.join(@root_path, 'workflow', 'sample_files', hpxml_name))
      hpxml_doc = hpxml.to_oga()
      # create the child element twice
      XMLHelper.create_elements_as_needed(hpxml_doc, elements.split('/')[1..-1])
      parent = XMLHelper.get_element(hpxml_doc, elements.split('/')[1...-1].join('/'))
      XMLHelper.add_element(parent, elements.split('/')[-1])

      if not child_elements_with_values.nil?
        child_elements_with_values.split(' and ')

        XMLHelper.get_elements(parent, elements.split('/')[-1]).each do |e|
          child_elements_with_values.split(' and ').each do |element_with_value|
            XMLHelper.add_element(e, element_with_value.split('=')[0], element_with_value.split('=')[1].gsub!(/\A"|"\Z/, ''))
          end
        end
      end
      XMLHelper.write_file(hpxml_doc, @tmp_hpxml_path)
      _test_schematron_validation(@tmp_hpxml_path, value)
    end
  end

  def test_invalid_files_validator_validation
    expected_error_msgs = { 
      ['/HPXML/XMLTransactionHeaderInformation/XMLType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/XMLTransactionHeaderInformation/XMLType",
      ['/HPXML/XMLTransactionHeaderInformation/XMLGeneratedBy'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/XMLTransactionHeaderInformation/XMLGeneratedBy",
      ['/HPXML/XMLTransactionHeaderInformation/CreatedDateAndTime'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/XMLTransactionHeaderInformation/CreatedDateAndTime",
      ['/HPXML/XMLTransactionHeaderInformation/Transaction'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/XMLTransactionHeaderInformation/Transaction",
      ['/HPXML/Building'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building",
      ['/HPXML/Building/BuildingID'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingID",
      ['/HPXML/Building/ProjectStatus/EventType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/ProjectStatus/EventType",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/HousePressure'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()=\"ACH\" or text()=\"CFM\"]] | /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[BuildingAirLeakage/UnitofMeasure[text()=\"ACHnatural\"]]",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/BuildingAirLeakage/UnitofMeasure'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()=\"ACH\" or text()=\"CFM\"]] | /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[BuildingAirLeakage/UnitofMeasure[text()=\"ACHnatural\"]]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofConditionedFloors'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: NumberofConditionedFloors",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofConditionedFloorsAboveGrade'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: NumberofConditionedFloorsAboveGrade",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofBedrooms'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: NumberofBedrooms",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/ConditionedFloorArea'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: ConditionedFloorArea",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/ConditionedBuildingVolume'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: ConditionedBuildingVolume | AverageCeilingHeight",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors: NeighborBuilding",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Azimuth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding: Azimuth",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Distance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding: Distance",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC/Year'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC: Year",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC/ClimateZone'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC: ClimateZone[text()=\"1A\" or text()=\"1B\" or text()=\"1C\" or text()=\"2A\" or text()=\"2B\" or text()=\"2C\" or text()=\"3A\" or text()=\"3B\" or text()=\"3C\" or text()=\"4A\" or text()=\"4B\" or text()=\"4C\" or text()=\"5A\" or text()=\"5B\" or text()=\"5C\" or text()=\"6A\" or text()=\"6B\" or text()=\"6C\" or text()=\"7\" or text()=\"8\"]",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/Name'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation: Name",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation/WMO'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/WeatherStation: WMO | extension/EPWFilePath",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()="ACH" or text()="CFM"]]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()=\"ACH\" or text()=\"CFM\"]] | /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[BuildingAirLeakage/UnitofMeasure[text()=\"ACHnatural\"]]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()="ACH" or text()="CFM"]]/BuildingAirLeakage/AirLeakage'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()=\"ACH\" or text()=\"CFM\"]] | /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[BuildingAirLeakage/UnitofMeasure[text()=\"ACHnatural\"]]: BuildingAirLeakage/AirLeakage",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: InteriorAdjacentTo[text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"living space\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/SolarAbsorptance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: SolarAbsorptance",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Emittance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Emittance",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Pitch'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Pitch",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/RadiantBarrier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: RadiantBarrier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Insulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Insulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Insulation/AssemblyEffectiveRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/ExteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: ExteriorAdjacentTo[text()=\"outside\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: InteriorAdjacentTo[text()=\"living space\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/WallType/WoodStud'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: WallType[WoodStud | DoubleWoodStud | ConcreteMasonryUnit | StructurallyInsulatedPanel | InsulatedConcreteForms | SteelFrame | SolidConcrete | StructuralBrick | StrawBale | Stone | LogWall]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/SolarAbsorptance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: SolarAbsorptance",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Emittance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: Emittance",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Insulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: Insulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Insulation/AssemblyEffectiveRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/ExteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: ExteriorAdjacentTo[text()=\"outside\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: InteriorAdjacentTo[text()=\"living space\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/SolarAbsorptance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: SolarAbsorptance",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Emittance'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: Emittance",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Insulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: Insulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Insulation/AssemblyEffectiveRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/ExteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: ExteriorAdjacentTo[text()=\"ground\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: InteriorAdjacentTo[text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Height'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Height",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Thickness'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Thickness",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/DepthBelowGrade'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: DepthBelowGrade",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Insulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Insulation/Layer[InstallationType=\"continuous - interior\"] | Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Insulation/Layer[InstallationType=\"continuous - exterior\"] | Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/NominalRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: NominalRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/extension/DistanceToTopOfInsulation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: extension/DistanceToTopOfInsulation",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - interior"]/extension/DistanceToBottomOfInsulation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: extension/DistanceToBottomOfInsulation",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/NominalRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: NominalRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/extension/DistanceToTopOfInsulation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: extension/DistanceToTopOfInsulation",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType="continuous - exterior"]/extension/DistanceToBottomOfInsulation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Insulation/Layer[InstallationType=\"continuous - exterior\" or InstallationType=\"continuous - interior\"]: extension/DistanceToBottomOfInsulation",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/ExteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: ExteriorAdjacentTo[text()=\"outside\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: InteriorAdjacentTo[text()=\"living space\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Insulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: Insulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor/Insulation/AssemblyEffectiveRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor: Insulation/AssemblyEffectiveRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor[ExteriorAdjacentTo[text()="other housing unit"]]/extension/OtherSpaceAboveOrBelow'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FrameFloors/FrameFloor[ExteriorAdjacentTo[text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]]: extension/OtherSpaceAboveOrBelow[text()=\"above\" or text()=\"below\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/InteriorAdjacentTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: InteriorAdjacentTo[text()=\"living space\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"garage\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/Thickness'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: Thickness",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/ExposedPerimeter'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: ExposedPerimeter",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulationDepth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: PerimeterInsulationDepth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulationWidth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: UnderSlabInsulationWidth | UnderSlabInsulationSpansEntireSlab[text()=\"true\"]",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: PerimeterInsulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/PerimeterInsulation/Layer[InstallationType="continuous"]/NominalRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: PerimeterInsulation/Layer[InstallationType=\"continuous\"]/NominalRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulation/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: UnderSlabInsulation/SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/UnderSlabInsulation/Layer[InstallationType="continuous"]/NominalRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: UnderSlabInsulation/Layer[InstallationType=\"continuous\"]/NominalRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/extension/CarpetFraction'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: extension/CarpetFraction",
      ['/HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab/extension/CarpetRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Slabs/Slab: extension/CarpetRValue",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Azimuth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/UFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: UFactor",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/SHGC'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: SHGC",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/AttachedToWall'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: AttachedToWall",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/Depth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs: Depth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/DistanceToTopOfWindow'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs: DistanceToTopOfWindow",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs/DistanceToBottomOfWindow'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs: DistanceToBottomOfWindow",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/Area'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: Area",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/Azimuth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/UFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: UFactor",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/SHGC'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: SHGC",
      ['/HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight/AttachedToRoof'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Skylights/Skylight: AttachedToRoof",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: ../../HVACControl",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/HeatingSystemType/Furnace'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: HeatingSystemType[ElectricResistance | Furnace | WallFurnace | FloorFurnace | Boiler | Stove | PortableHeater | Fireplace]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/FractionHeatLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: FractionHeatLoadServed",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType/AirDistribution]'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: ../../HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other=\"DSE\"]]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/DistributionSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: DistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/HeatingSystemFuel'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: HeatingSystemFuel[text()=\"natural gas\" or text()=\"fuel oil\" or text()=\"propane\" or text()=\"electricity\" or text()=\"wood\" or text()=\"wood pellets\"]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]/AnnualHeatingEfficiency[Units="AFUE"]/Value'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: AnnualHeatingEfficiency[Units=\"AFUE\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingSystemType[text()="central air conditioner" or text()="room air conditioner" or text()="evaporative cooler"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem: CoolingSystemType[text()=\"central air conditioner\" or text()=\"room air conditioner\" or text()=\"evaporative cooler\"]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingSystemFuel[text()="electricity"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem: CoolingSystemFuel[text()=\"electricity\"]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/FractionCoolLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem: FractionCoolLoadServed",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other="DSE"]]'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: ../../HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other=\"DSE\"]]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/DistributionSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"central air conditioner\"]: DistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/AnnualCoolingEfficiency[Units="SEER"]/Value'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"central air conditioner\"]: AnnualCoolingEfficiency[Units=\"SEER\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatPumpType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: HeatPumpType[text()=\"air-to-air\" or text()=\"mini-split\" or text()=\"ground-to-air\"]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatPumpFuel'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: HeatPumpFuel[text()=\"electricity\"]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/FractionHeatLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: FractionHeatLoadServed",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/FractionCoolLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: FractionCoolLoadServed",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/DistributionSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"air-to-air\"]: DistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/AnnualCoolingEfficiency[Units="SEER"]/Value'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"air-to-air\"]: AnnualCoolingEfficiency[Units=\"SEER\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/AnnualHeatingEfficiency[Units="HSPF"]/Value'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"air-to-air\"]: AnnualHeatingEfficiency[Units=\"HSPF\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetpointTempHeatingSeason'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: SetpointTempHeatingSeason",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetpointTempCoolingSeason'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: SetpointTempCoolingSeason",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]/TotalSetbackHoursperWeekHeating'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]: TotalSetbackHoursperWeekHeating",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]/extension/SetbackStartHourHeating'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetbackTempHeatingSeason]: extension/SetbackStartHourHeating",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]/TotalSetupHoursperWeekCooling'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]: TotalSetupHoursperWeekCooling",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]/extension/SetupStartHourCooling'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl[SetupTempCoolingSeason]: extension/SetupStartHourCooling",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem[HeatingSystemType/Furnace]: ../../HVACDistribution[DistributionSystemType/AirDistribution | DistributionSystemType[Other=\"DSE\"]]",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/ConditionedFloorAreaServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution: ../../ConditionedFloorAreaServed",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/DuctLeakageMeasurement[DuctType="supply"]/DuctLeakage[(Units="CFM25" or Units="Percent") and TotalOrToOutside="to outside"]/Value'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution: DuctLeakageMeasurement[DuctType=\"supply\"]/DuctLeakage[(Units=\"CFM25\" or Units=\"Percent\") and TotalOrToOutside=\"to outside\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other="DSE"]]/AnnualHeatingDistributionSystemEfficiency', '/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other="DSE"]]/AnnualCoolingDistributionSystemEfficiency'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution[DistributionSystemType[Other=\"DSE\"]]: AnnualHeatingDistributionSystemEfficiency | AnnualCoolingDistributionSystemEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctInsulationRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType=\"supply\" or DuctType=\"return\"]: DuctInsulationRValue",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctSurfaceArea | DuctLocation[text()="living space" or text()="basement - conditioned" or text()="basement - unconditioned" or text()="crawlspace - vented" or text()="crawlspace - unvented" or text()="attic - vented" or text()="attic - unvented" or text()="garage" or text()="exterior wall" or text()="under slab" or text()="roof deck" or text()="outside" or text()="other housing unit" or text()="other heated space" or text()="other multifamily buffer space" or text()="other non-freezing space"]'] => "Expected [0, 2] element(s) but found 1 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType=\"supply\" or DuctType=\"return\"]: DuctSurfaceArea | DuctLocation[text()=\"living space\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"garage\" or text()=\"exterior wall\" or text()=\"under slab\" or text()=\"roof deck\" or text()=\"outside\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/FanType[text()="energy recovery ventilator" or text()="heat recovery ventilator" or text()="exhaust only" or text()="supply only" or text()="balanced" or text()="central fan integrated supply"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]: FanType[text()=\"energy recovery ventilator\" or text()=\"heat recovery ventilator\" or text()=\"exhaust only\" or text()=\"supply only\" or text()=\"balanced\" or text()=\"central fan integrated supply\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/TestedFlowRate'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]: TestedFlowRate | RatedFlowRate",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/HoursInOperation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]: HoursInOperation",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true"]/FanPower'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]: FanPower",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="heat recovery ventilator"]/SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\" and FanType=\"heat recovery ventilator\"]: SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="energy recovery ventilator"]/TotalRecoveryEfficiency | AdjustedTotalRecoveryEfficiency'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\" and FanType=\"energy recovery ventilator\"]: TotalRecoveryEfficiency | AdjustedTotalRecoveryEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="energy recovery ventilator"]/SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\" and FanType=\"energy recovery ventilator\"]: SensibleRecoveryEfficiency | AdjustedSensibleRecoveryEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation="true" and FanType="central fan integrated supply"]/AttachedToHVACDistributionSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\" and FanType=\"central fan integrated supply\"]: AttachedToHVACDistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction=\"true\"]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/RatedFlowRate'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction=\"true\"]: RatedFlowRate",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction="true"]/FanPower'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction=\"true\"]: FanPower",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: ../HotWaterDistribution",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture'] => "Expected 1 or more element(s) but found 0 elements for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: ../WaterFixture",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/WaterHeaterType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: WaterHeaterType[text()=\"storage water heater\" or text()=\"instantaneous water heater\" or text()=\"heat pump water heater\" or text()=\"space-heating boiler with storage tank\" or text()=\"space-heating boiler with tankless coil\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/FractionDHWLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: FractionDHWLoadServed",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/FuelType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: FuelType[text()=\"natural gas\" or text()=\"fuel oil\" or text()=\"propane\" or text()=\"electricity\" or text()=\"wood\" or text()=\"wood pellets\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/EnergyFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: EnergyFactor | UniformEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/FuelType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"instantaneous water heater\"]: FuelType[text()=\"natural gas\" or text()=\"fuel oil\" or text()=\"propane\" or text()=\"electricity\" or text()=\"wood\" or text()=\"wood pellets\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/EnergyFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"instantaneous water heater\"]: EnergyFactor | UniformEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/FuelType'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"heat pump water heater\"]: FuelType[text()=\"electricity\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/TankVolume'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"heat pump water heater\"]: TankVolume",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/EnergyFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"heat pump water heater\"]: EnergyFactor | UniformEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/RelatedHVACSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"space-heating boiler with storage tank\"]: RelatedHVACSystem",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/TankVolume'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"space-heating boiler with storage tank\"]: TankVolume",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with tankless coil"]/RelatedHVACSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"space-heating boiler with tankless coil\"]: RelatedHVACSystem",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater="true"]/WaterHeaterType[text()="storage water heater" or text()="instantaneous water heater" or text()="heat pump water heater"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: WaterHeaterType[text()=\"storage water heater\" or text()=\"instantaneous water heater\" or text()=\"heat pump water heater\" or text()=\"space-heating boiler with storage tank\" or text()=\"space-heating boiler with tankless coil\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater="true"]/RelatedHVACSystem'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[UsesDesuperheater=\"true\"]: RelatedHVACSystem",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Standard'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution: SystemType/Standard | SystemType/Recirculation",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/PipeInsulation/PipeRValue'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution: PipeInsulation/PipeRValue",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/ControlType[text()="manual demand control" or text()="presence sensor demand control" or text()="temperature" or text()="timer" or text()="no control"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation: ControlType[text()=\"manual demand control\" or text()=\"presence sensor demand control\" or text()=\"temperature\" or text()=\"timer\" or text()=\"no control\"]",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/FacilitiesConnected'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery: FacilitiesConnected",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/EqualFlow'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery: EqualFlow",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery/Efficiency'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery: Efficiency",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture: SystemIdentifier", 
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/WaterFixtureType[text()="shower head" or text()="faucet"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture: WaterFixtureType[text()=\"shower head\" or text()=\"faucet\"]", 
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/LowFlow'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture: LowFlow",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/SystemType[text()="hot water"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem: SystemType[text()=\"hot water\"]",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem/CollectorArea'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem: CollectorArea | SolarFraction",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorLoopType[text()="liquid indirect" or text()="liquid direct" or text()="passive thermosyphon"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorLoopType[text()=\"liquid indirect\" or text()=\"liquid direct\" or text()=\"passive thermosyphon\"]",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorType[text()="single glazing black" or text()="double glazing black" or text()="evacuated tube" or text()="integrated collector storage"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorType[text()=\"single glazing black\" or text()=\"double glazing black\" or text()=\"evacuated tube\" or text()=\"integrated collector storage\"]",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorAzimuth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorAzimuth",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorTilt'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorTilt",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorRatedOpticalEfficiency'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorRatedOpticalEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/CollectorRatedThermalLosses'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: CollectorRatedThermalLosses",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/ConnectedTo'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: ConnectedTo",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/Location[text()="ground" or text()="roof"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: Location[text()=\"ground\" or text()=\"roof\"]",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ModuleType[text()="standard" or text()="premium" or text()="thin film"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: ModuleType[text()=\"standard\" or text()=\"premium\" or text()=\"thin film\"]",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/Tracking[text()="fixed" or text()="1-axis" or text()="1-axis backtracked" or text()="2-axis"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: Tracking[text()=\"fixed\" or text()=\"1-axis\" or text()=\"1-axis backtracked\" or text()=\"2-axis\"]",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ArrayAzimuth'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: ArrayAzimuth",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/ArrayTilt'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: ArrayTilt",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/MaxPowerOutput'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: MaxPowerOutput",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesWasher: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/IntegratedModifiedEnergyFactor'] => "Expected [0, 7] element(s) but found 6 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesWasher: ModifiedEnergyFactor | IntegratedModifiedEnergyFactor | RatedAnnualkWh | LabelElectricRate | LabelGasRate | LabelAnnualGasCost | LabelUsage | Capacity",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesDryer: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/FuelType[text()="natural gas" or text()="fuel oil" or text()="propane" or text()="electricity" or text()="wood" or text()="wood pellets"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesDryer: FuelType[text()=\"natural gas\" or text()=\"fuel oil\" or text()=\"propane\" or text()=\"electricity\" or text()=\"wood\" or text()=\"wood pellets\"]",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dishwasher: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/RatedAnnualkWh'] => "Expected [0, 6] element(s) but found 5 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dishwasher: RatedAnnualkWh | EnergyFactor | LabelElectricRate | LabelGasRate | LabelAnnualGasCost | LabelUsage | PlaceSettingCapacity",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/Capacity'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dehumidifier: Capacity",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/EnergyFactor | IntegratedEnergyFactor'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dehumidifier: EnergyFactor | IntegratedEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/DehumidistatSetpoint'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dehumidifier: DehumidistatSetpoint",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier/FractionDehumidificationLoadServed'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dehumidifier: FractionDehumidificationLoadServed",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/FuelType[text()="natural gas" or text()="fuel oil" or text()="propane" or text()="electricity" or text()="wood" or text()="wood pellets"]'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: FuelType[text()=\"natural gas\" or text()=\"fuel oil\" or text()=\"propane\" or text()=\"electricity\" or text()=\"wood\" or text()=\"wood pellets\"]",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]'] => "Expected [9] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting: LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()=\"interior\" or text()=\"exterior\" or text()=\"garage\"]]",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()=\"interior\" or text()=\"exterior\" or text()=\"garage\"]]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()="interior" or text()="exterior" or text()="garage"]]/FractionofUnitsInLocation'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/LightingGroup[LightingType[LightEmittingDiode | CompactFluorescent | FluorescentTube] and Location[text()=\"interior\" or text()=\"exterior\" or text()=\"garage\"]]: FractionofUnitsInLocation",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/CeilingFan: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: SystemIdentifier",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/SystemIdentifier'] => "Expected [1] element(s) but found 0 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: SystemIdentifier",
    }
    
    expected_error_msgs.each do |keys, value|
      hpxml_name = get_hpxml_file_name(keys[0])
      hpxml = HPXML.new(hpxml_path: File.join(@root_path, 'workflow', 'sample_files', hpxml_name))
      hpxml_doc = hpxml.to_oga()
      keys.each do |key|
        XMLHelper.delete_element(hpxml_doc, key)
      end
      XMLHelper.write_file(hpxml_doc, @tmp_hpxml_path)
      _test_ruby_validation(hpxml_doc, value)
    end
    
    # Test for optional elements (i.e. zero_or_one, zero_or_two, etc.)
    expected_error_msgs_optional = {
      ['/HPXML/SoftwareInfo/extension/SimulationControl', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/SoftwareInfo/extension/SimulationControl",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site', 'SiteType="suburban"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/SiteType[text()=\"urban\" or text()=\"suburban\" or text()=\"rural\"]",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/ShelterCoefficient', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/ShelterCoefficient",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingOccupancy/NumberofResidents', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingOccupancy/NumberofResidents",
      ['/HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/ClimateandRiskZones/ClimateZoneIECC",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl", # FIXME: Need to review this case
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForWholeBuildingVentilation="true"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForWholeBuildingVentilation=\"true\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForLocalVentilation="true" and FanLocation="kitchen"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForLocalVentilation="true" and FanLocation="bath"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan', 'UsedForSeasonalCoolingLoadReduction="true"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForSeasonalCoolingLoadReduction=\"true\"]",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesWasher",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesDryer",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dishwasher",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator",
      ['/HPXML/Building/BuildingDetails/Appliances/Dehumidifier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dehumidifier",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange",
      ['/HPXML/Building/BuildingDetails/Lighting', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/CeilingFan",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad', 'PlugLoadType="other"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad', 'PlugLoadType="TV other"'] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]",
      ['/HPXML/SoftwareInfo/extension/SimulationControl/Timestep', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/SoftwareInfo/extension/SimulationControl: Timestep",
      ['/HPXML/SoftwareInfo/extension/SimulationControl', 'BeginMonth=1'] => "Expected [0, 2] element(s) but found 1 element(s) for xpath: /HPXML/SoftwareInfo/extension/SimulationControl: BeginMonth | BeginDayOfMonth",
      ['/HPXML/SoftwareInfo/extension/SimulationControl', 'EndMonth=12'] => "Expected [0, 2] element(s) but found 1 element(s) for xpath: /HPXML/SoftwareInfo/extension/SimulationControl: EndMonth | EndDayOfMonth",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction/NumberofBathrooms', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/BuildingConstruction: NumberofBathrooms",
      ['/HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding/Height', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/BuildingSummary/Site/extension/Neighbors/NeighborBuilding: Height",
      ['/HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement/InfiltrationVolume', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[number(HousePressure)=50 and BuildingAirLeakage/UnitofMeasure[text()=\"ACH\" or text()=\"CFM\"]] | /HPXML/Building/BuildingDetails/Enclosure/AirInfiltration/AirInfiltrationMeasurement[BuildingAirLeakage/UnitofMeasure[text()=\"ACHnatural\"]]: InfiltrationVolume", # FIXME: Need to review parent Xpath
      ['/HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof/Azimuth', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Attics/Attic/VentilationRate/Value', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Roofs/Roof[InteriorAdjacentTo=\"attic - vented\"]: ../../Attics/Attic[AtticType/Attic[Vented=\"true\"]]/VentilationRate[UnitofMeasure=\"SLA\" or UnitofMeasure=\"ACHnatural\"]/Value", # FIXME: Review this!
      ['/HPXML/Building/BuildingDetails/Enclosure/Walls/Wall/Azimuth', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Walls/Wall: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist/Azimuth', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/RimJoists/RimJoist: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall/Azimuth', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall: Azimuth",
      ['/HPXML/Building/BuildingDetails/Enclosure/Foundations/Foundation/VentilationRate/Value', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/FoundationWalls/FoundationWall[InteriorAdjacentTo=\"crawlspace - vented\"]: ../../Foundations/Foundation[FoundationType/Crawlspace[Vented=\"true\"]]/VentilationRate[UnitofMeasure=\"SLA\"]/Value", # FIXME: Review this!
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/InteriorShading/SummerShadingCoefficient', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: InteriorShading/SummerShadingCoefficient",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/InteriorShading/WinterShadingCoefficient', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: InteriorShading/WinterShadingCoefficient",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/Overhangs', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: Overhangs",
      ['/HPXML/Building/BuildingDetails/Enclosure/Windows/Window/FractionOperable', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Enclosure/Windows/Window: FractionOperable",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/HeatingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: HeatingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem/ElectricAuxiliaryEnergy', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatingSystem: ElectricAuxiliaryEnergy",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/CoolingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"central air conditioner\"]: CoolingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="central air conditioner"]/SensibleHeatFraction', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"central air conditioner\"]: SensibleHeatFraction",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]/CoolingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"room air conditioner\"]: CoolingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="room air conditioner"]/SensibleHeatFraction', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"room air conditioner\"]: SensibleHeatFraction",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType="evaporative cooler"]/DistributionSystem', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/CoolingSystem[CoolingSystemType=\"evaporative cooler\"]: DistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/HeatingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: HeatingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/CoolingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: CoolingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump/CoolingSensibleHeatFraction', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump: CoolingSensibleHeatFraction",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="air-to-air"]/HeatingCapacity17F', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"air-to-air\"]: HeatingCapacity17F",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="mini-split"]/DistributionSystem', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"mini-split\"]: DistributionSystem",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType="mini-split"]/HeatingCapacity17F', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[HeatPumpType=\"mini-split\"]: HeatingCapacity17F",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]/BackupHeatingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]: BackupHeatingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]/BackupHeatingSwitchoverTemperature', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACPlant/HeatPump[BackupSystemFuel]: BackupHeatingSwitchoverTemperature",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetbackTempHeatingSeason', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: SetbackTempHeatingSeason",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/SetupTempCoolingSeason', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: SetupTempCoolingSeason",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl/extension/CeilingFanSetpointTempCoolingSeasonOffset', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACControl: extension/CeilingFanSetpointTempCoolingSeasonOffset",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/DuctLeakageMeasurement[DuctType="return"]/DuctLeakage[(Units="CFM25" or Units="Percent") and TotalOrToOutside="to outside"]/Value', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution: DuctLeakageMeasurement[DuctType=\"return\"]/DuctLeakage[(Units=\"CFM25\" or Units=\"Percent\") and TotalOrToOutside=\"to outside\"]/Value",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/NumberofReturnRegisters', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution: NumberofReturnRegisters",
      ['/HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType="supply" or DuctType="return"]/DuctSurfaceArea', nil] => "Expected [0, 2] element(s) but found 3 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/HVAC/HVACDistribution/DistributionSystemType/AirDistribution/Ducts[DuctType=\"supply\" or DuctType=\"return\"]: DuctSurfaceArea | DuctLocation[text()=\"living space\" or text()=\"basement - conditioned\" or text()=\"basement - unconditioned\" or text()=\"crawlspace - vented\" or text()=\"crawlspace - unvented\" or text()=\"attic - vented\" or text()=\"attic - unvented\" or text()=\"garage\" or text()=\"exterior wall\" or text()=\"under slab\" or text()=\"roof deck\" or text()=\"outside\" or text()=\"other housing unit\" or text()=\"other heated space\" or text()=\"other multifamily buffer space\" or text()=\"other non-freezing space\"]",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/RatedFlowRate', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]: RatedFlowRate",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/HoursInOperation', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]: HoursInOperation",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/FanPower', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]: FanPower",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="kitchen"]/extension/StartHour', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"kitchen\"]: extension/StartHour",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/Quantity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: Quantity",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/RatedFlowRate', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: RatedFlowRate",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/HoursInOperation', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: HoursInOperation",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/FanPower', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: FanPower",
      ['/HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation="true" and FanLocation="bath"]/extension/StartHour', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/MechanicalVentilation/VentilationFans/VentilationFan[UsedForLocalVentilation=\"true\" and FanLocation=\"bath\"]: extension/StartHour",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/HotWaterTemperature', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: HotWaterTemperature",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem/UsesDesuperheater', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem: UsesDesuperheater",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/TankVolume', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: TankVolume",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/HeatingCapacity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: HeatingCapacity",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/EnergyFactor', nil] => "Expected [1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: EnergyFactor | UniformEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/RecoveryEfficiency', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: RecoveryEfficiency",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="storage water heater"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"storage water heater\"]: WaterHeaterInsulation/Jacket/JacketRValue",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/PerformanceAdjustment', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"instantaneous water heater\"]: PerformanceAdjustment",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="instantaneous water heater"]/EnergyFactor', nil] => "Expected [1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"instantaneous water heater\"]: EnergyFactor | UniformEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="heat pump water heater"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"heat pump water heater\"]: WaterHeaterInsulation/Jacket/JacketRValue",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/WaterHeaterInsulation/Jacket/JacketRValue', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"space-heating boiler with storage tank\"]: WaterHeaterInsulation/Jacket/JacketRValue",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType="space-heating boiler with storage tank"]/StandbyLoss', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterHeatingSystem[WaterHeaterType=\"space-heating boiler with storage tank\"]: StandbyLoss",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/DrainWaterHeatRecovery', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution: DrainWaterHeatRecovery",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Standard/PipingLength', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Standard: PipingLength",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/RecirculationPipingLoopLength', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation: RecirculationPipingLoopLength",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/BranchPipingLoopLength', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation: BranchPipingLoopLength",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation/PumpPower', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/HotWaterDistribution/SystemType/Recirculation: PumpPower",
      ['/HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture/../extension/WaterFixturesUsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/WaterHeating/WaterFixture: ../extension/WaterFixturesUsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]/StorageVolume', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[CollectorArea]: StorageVolume",
      ['/HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[SolarFraction]/ConnectedTo', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/SolarThermal/SolarThermalSystem[SolarFraction]: ConnectedTo",
      ['/HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem/InverterEfficiency', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Systems/Photovoltaics/PVSystem: InverterEfficiency",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/IntegratedModifiedEnergyFactor', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesWasher: ModifiedEnergyFactor | IntegratedModifiedEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesWasher/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesWasher: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/CombinedEnergyFactor', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesDryer: EnergyFactor | CombinedEnergyFactor",
      ['/HPXML/Building/BuildingDetails/Appliances/ClothesDryer/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/ClothesDryer: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/RatedAnnualkWh', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dishwasher: RatedAnnualkWh | EnergyFactor",
      ['/HPXML/Building/BuildingDetails/Appliances/Dishwasher/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Dishwasher: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/WeekdayScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator: extension/WeekdayScheduleFractions",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/WeekendScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator: extension/WeekendScheduleFractions",
      ['/HPXML/Building/BuildingDetails/Appliances/Refrigerator/extension/MonthlyScheduleMultipliers', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/Refrigerator: extension/MonthlyScheduleMultipliers",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/IsInduction', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: IsInduction",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/WeekdayScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: extension/WeekdayScheduleFractions",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/WeekendScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: extension/WeekendScheduleFractions",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/extension/MonthlyScheduleMultipliers', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: extension/MonthlyScheduleMultipliers",
      ['/HPXML/Building/BuildingDetails/Appliances/CookingRange/../Oven/IsConvection', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Appliances/CookingRange: ../Oven/IsConvection",
      ['/HPXML/Building/BuildingDetails/Lighting/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/Airflow/Efficiency', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/CeilingFan: Airflow[FanSpeed=\"medium\"]/Efficiency",
      ['/HPXML/Building/BuildingDetails/Lighting/CeilingFan/Quantity', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/Lighting/CeilingFan: Quantity",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/Load/Value', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: Load[Units=\"kWh/year\"]/Value",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/FracSensible', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: extension/FracSensible",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/FracLatent', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: extension/FracLatent",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/WeekdayScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: ../extension/WeekdayScheduleFractions",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/WeekendScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: ../extension/WeekendScheduleFractions",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="other"]/../extension/MonthlyScheduleMultipliers', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"other\"]: ../extension/MonthlyScheduleMultipliers",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/Load/Value', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: Load[Units=\"kWh/year\"]/Value",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/extension/UsageMultiplier', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: extension/UsageMultiplier",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/WeekdayScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: ../extension/WeekdayScheduleFractions",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/WeekendScheduleFractions', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: ../extension/WeekendScheduleFractions",
      ['/HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType="TV other"]/../extension/MonthlyScheduleMultipliers', nil] => "Expected [0, 1] element(s) but found 2 element(s) for xpath: /HPXML/Building/BuildingDetails/MiscLoads/PlugLoad[PlugLoadType=\"TV other\"]: ../extension/MonthlyScheduleMultipliers",
    }
    
    expected_error_msgs_optional.each do |key, value|
      elements = key[0]
      child_elements_with_values = key[1]
      hpxml_name = get_hpxml_file_name(elements)
      hpxml = HPXML.new(hpxml_path: File.join(@root_path, 'workflow', 'sample_files', hpxml_name))
      hpxml_doc = hpxml.to_oga()
      # create the child element twice
      XMLHelper.create_elements_as_needed(hpxml_doc, elements.split('/')[1..-1])
      parent = XMLHelper.get_element(hpxml_doc, elements.split('/')[1...-1].join('/'))
      XMLHelper.add_element(parent, elements.split('/')[-1])

      if not child_elements_with_values.nil?
        XMLHelper.get_elements(parent, elements.split('/')[-1]).each do |e|
          child_elements_with_values.split(' and ').each do |element_with_value|
            XMLHelper.add_element(e, element_with_value.split('=')[0], element_with_value.split('=')[1].gsub!(/\A"|"\Z/, '')) if not XMLHelper.has_element(e, element_with_value.split('=')[0])
          end
        end
      end
      XMLHelper.write_file(hpxml_doc, @tmp_hpxml_path)
      _test_ruby_validation(hpxml_doc, value)
    end
  end

  def _test_schematron_validation(hpxml_path, expected_error_msgs = nil)
    # load the schematron xml
    stron_doc = Nokogiri::XML File.open(File.join(@root_path, 'HPXMLtoOpenStudio', 'resources', 'EPvalidator.xml'))  # "/path/to/schema.stron"
    # make a schematron object
    stron = SchematronNokogiri::Schema.new stron_doc
    # load the xml document you wish to validate
    xml_doc = Nokogiri::XML File.open(hpxml_path)  # "/path/to/xml_document.xml"
    # validate it
    results = stron.validate xml_doc
    # assertions
    if expected_error_msgs.nil?
      assert_empty(results)
    else
      idx_of_interest = results.index { |i| i[:message] == expected_error_msgs }
      assert_equal(expected_error_msgs, results[idx_of_interest][:message])
    end
  end

  def _test_ruby_validation(hpxml_doc, expected_error_msgs = nil)
    # Validate input HPXML against EnergyPlus Use Case
    results = EnergyPlusValidator.run_validator(hpxml_doc)
    if expected_error_msgs.nil?
      assert_empty(results)
    else
      idx_of_interest = results.index { |i| i == expected_error_msgs }
      assert_equal(expected_error_msgs, results[idx_of_interest])
    end
  end
end