model Do_tof "Doppler ToF heterodyne and homodyne model"
  extends ModelWorkspace;
  import SysplorerEmbeddedCoder.Types.*;
  import BaseWorkspace.*;
  annotation(__MWORKS(version="26.3.0",modelType=Control,PortArrangement,BlockSystem(blockKind=BlockKind.userModel,SampleTime(auto=true),ExternalCResource(SavedInRelationPath=false,IncludeFile,SourceFile,Library,IncludeDirectory={"classDirectory()/"},LibraryDirectory={"classDirectory()/"}),OutputInterval=1.66666670138889e-10),SysblockVersion="1.0"),Icon(coordinateSystem(preserveAspectRatio=false)),Diagram(graphics={Text(origin = { 44,32 },lineColor = { 0,0,0 },extent = { { -13.26,-7 },{ 13.26,7 } },textString = "Subtract",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -6,52 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Integral",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -40,-96 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Multiply",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -40,-56 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Multiply",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -40,11 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Multiply",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -40,52 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Multiply",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -6,11 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Integral",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -6,-56 },lineColor = { 0,0,0 },extent = { {
-11.9,-7 },{
11.9
,7 } },textString = "Integral",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { -6,-96 },lineColor = { 0,0,0 },extent = { { -11.9,-7 },{ 11.9,7 } },textString = "Integral",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { 44,-72 },lineColor = { 0,0,0 },extent = { { -13.26,-7 },{ 13.26,7 } },textString = "Subtract",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left),Text(origin = { 105,-22 },lineColor = { 0,0,0 },extent = { { -9.86,-7 },{ 9.86,7 } },textString = "Divide",fontSize = 20,textStyle = { TextStyle.None },textColor = { 0,0,0 },horizontalAlignment = TextAlignment.Left)}));
  annotation(experiment(Algorithm=Euler,Interval=1.66666670138889e-10,StartTime=0,StopTime=0.008,IntegratorStep=1.66666670138889e-10,StoreEventValue=0));
  parameter Real fa = 60000000;
  parameter Real fb = 60001000;
  model ModelWorkspace
    annotation(__MWORKS(hide = true,BlockSystem(blockKind=BlockKind.modelWorkspace)));
  end ModelWorkspace;
  SysplorerEmbeddedCoder.MathOperation.Product Divide(inputs="2",isSaturate=false,multiplication=SysplorerEmbeddedCoder.MathOperation.Product.MultiplicationType.elementWise) 
    annotation (Placement(transformation(origin = {105.000000, -4.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="*",instance="u1"),label(text="/",instance="u2")))));
  FromWorkspace 'From10Workspace2'(var_name="Reflected_Light_Wave_Data") 
    annotation (Placement(transformation(origin = {-166.000000, 1.000000}, extent = {{-42.500000, -6.500000}, {42.500000, 6.500000}},rotation=0)),__MWORKS(BlockSystem(SampleTime(auto=false)=0)));
  SysplorerEmbeddedCoder.Continuous.Integrator Integrator(externalResetType=SysplorerEmbeddedCoder.Continuous.Integrator.ExternalResetType.None,zeroCross=true,initCond=0,initCondSourceType=SysplorerEmbeddedCoder.Continuous.Integrator.InitCondSourceType.Internal,limitOutput=false,wrapState=false,showSaturationPort=false,showStatePort=false) 
    annotation (Placement(transformation(origin = {-7.000000, 72.000000}, extent = {{-10.000000, -10.000000}, {10.000000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(zeroCross=true)));
  SysplorerEmbeddedCoder.Continuous.Integrator Integrator1(externalResetType=SysplorerEmbeddedCoder.Continuous.Integrator.ExternalResetType.None,zeroCross=true,initCond=0,initCondSourceType=SysplorerEmbeddedCoder.Continuous.Integrator.InitCondSourceType.Internal,limitOutput=false,wrapState=false,showSaturationPort=false,showStatePort=false) 
    annotation (Placement(transformation(origin = {-7.000000, 31.000000}, extent = {{-10.000000, -10.000000}, {10.000000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(zeroCross=true)));
  SysplorerEmbeddedCoder.Continuous.Integrator Integrator2(externalResetType=SysplorerEmbeddedCoder.Continuous.Integrator.ExternalResetType.None,zeroCross=true,initCond=0,initCondSourceType=SysplorerEmbeddedCoder.Continuous.Integrator.InitCondSourceType.Internal,limitOutput=false,wrapState=false,showSaturationPort=false,showStatePort=false) 
    annotation (Placement(transformation(origin = {-7.000000, -37.000000}, extent = {{-10.000000, -10.000000}, {10.000000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(zeroCross=true)));
  SysplorerEmbeddedCoder.Continuous.Integrator Integrator3(externalResetType=SysplorerEmbeddedCoder.Continuous.Integrator.ExternalResetType.None,zeroCross=true,initCond=0,initCondSourceType=SysplorerEmbeddedCoder.Continuous.Integrator.InitCondSourceType.Internal,limitOutput=false,wrapState=false,showSaturationPort=false,showStatePort=false) 
    annotation (Placement(transformation(origin = {-7.000000, -78.000000}, extent = {{-10.000000, -10.000000}, {10.000000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(zeroCross=true)));
  SysplorerEmbeddedCoder.MathOperation.Product Product(inputs="2",isSaturate=false,multiplication=SysplorerEmbeddedCoder.MathOperation.Product.MultiplicationType.elementWise) 
    annotation (Placement(transformation(origin = {-41.000000, 74.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="*",instance="u1"),label(text="*",instance="u2")))));
  SysplorerEmbeddedCoder.MathOperation.Product Product1(inputs="2",isSaturate=false,multiplication=SysplorerEmbeddedCoder.MathOperation.Product.MultiplicationType.elementWise) 
    annotation (Placement(transformation(origin = {-41.000000, 33.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="*",instance="u1"),label(text="*",instance="u2")))));
  SysplorerEmbeddedCoder.MathOperation.Product Product2(inputs="2",isSaturate=false,multiplication=SysplorerEmbeddedCoder.MathOperation.Product.MultiplicationType.elementWise) 
    annotation (Placement(transformation(origin = {-41.000000, -35.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="*",instance="u1"),label(text="*",instance="u2")))));
  SysplorerEmbeddedCoder.MathOperation.Product Product3(inputs="2",isSaturate=false,multiplication=SysplorerEmbeddedCoder.MathOperation.Product.MultiplicationType.elementWise) 
    annotation (Placement(transformation(origin = {-41.000000, -75.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="*",instance="u1"),label(text="*",instance="u2")))));
  SysplorerEmbeddedCoder.Sources.PulseGenerator 'Pulse10Generator6'(pulseType=SysplorerEmbeddedCoder.Sources.PulseGenerator.PulseType.timeBased,amplitude=1,period_time=1/(fb),width_time=50,phase_time=0,timeSource=SysplorerEmbeddedCoder.Sources.PulseGenerator.TimeSourceType.simulationTime) 
    annotation (Placement(transformation(origin = {-106.000000, -29.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(SampleTime(auto=true)=-1)));
  SysplorerEmbeddedCoder.Sources.PulseGenerator 'Pulse10Generator7'(pulseType=SysplorerEmbeddedCoder.Sources.PulseGenerator.PulseType.timeBased,amplitude=1,period_time=1/(fb),width_time=50,phase_time=0.5/(fb),timeSource=SysplorerEmbeddedCoder.Sources.PulseGenerator.TimeSourceType.simulationTime) 
    annotation (Placement(transformation(origin = {-106.000000, -70.000000}, extent = {{-10.000000, -11.500000}, {10.000000, 11.500000}},rotation=0)),__MWORKS(BlockSystem(SampleTime(auto=true)=-1)));
  SysplorerEmbeddedCoder.Sources.PulseGenerator 'Pulse10Generator8'(pulseType=SysplorerEmbeddedCoder.Sources.PulseGenerator.PulseType.timeBased,amplitude=1,period_time=1/(fa),width_time=50,phase_time=0.5/(fa),timeSource=SysplorerEmbeddedCoder.Sources.PulseGenerator.TimeSourceType.simulationTime) 
    annotation (Placement(transformation(origin = {-106.000000, 39.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(SampleTime(auto=true)=-1)));
  SysplorerEmbeddedCoder.Sources.PulseGenerator 'Pulse10Generator9'(pulseType=SysplorerEmbeddedCoder.Sources.PulseGenerator.PulseType.timeBased,amplitude=1,period_time=1/(fa),width_time=50,phase_time=0,timeSource=SysplorerEmbeddedCoder.Sources.PulseGenerator.TimeSourceType.simulationTime) 
    annotation (Placement(transformation(origin = {-106.000000, 80.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(SampleTime(auto=true)=-1)));
  SysplorerEmbeddedCoder.MathOperation.Sum Subtract(inputs="+-",isSaturate=false) 
    annotation (Placement(transformation(origin = {44.000000, 50.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="+",instance="u1"),label(text="-",instance="u2")))));
  SysplorerEmbeddedCoder.MathOperation.Sum Subtract1(inputs="+-",isSaturate=false) 
    annotation (Placement(transformation(origin = {44.000000, -55.000000}, extent = {{-10.000000, -10.500000}, {10.000000, 10.500000}},rotation=0)),__MWORKS(BlockSystem(Instance(u(u1,u2),y(Type(inherit=InheritType.internalRule))),Type(overflowKind=SysplorerEmbeddedCoder.Types.OverflowKind.wrap)),PortLabels(labelType="CustomType",labels(label(text="+",instance="u1"),label(text="-",instance="u2")))));
  ToWorkspace 'To Workspace'(var_name="simout",extract=0,max_data_point=1) 
    annotation (Placement(transformation(origin = {166.000000, -6.000000}, extent = {{-30.500000, -10.000000}, {30.500000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(SampleTime=-1)));
  ToWorkspace1 'To Workspace1'(var_name="Heterodyne",extract=0,max_data_point=1) 
    annotation (Placement(transformation(origin = {166.000000, -57.000000}, extent = {{-30.500000, -10.000000}, {30.500000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(SampleTime=-1)));
  ToWorkspace2 'To Workspace2'(var_name="Homodyne",extract=0,max_data_point=1) 
    annotation (Placement(transformation(origin = {166.000000, 48.000000}, extent = {{-30.500000, -10.000000}, {30.500000, 10.000000}},rotation=0)),__MWORKS(BlockSystem(SampleTime=-1)));
  block FromWorkspace "从Syslab工作区读取向量格式的数据值"
   annotation(defaultComponentName = "fromWorkspace",__MWORKS(PortArrangement(Right(outport)),BlockSystem(blockKind=Types.BlockKind.composite, bltBlockKind=Types.BltBlockKind.fromWorkspace),sourceModel=SysplorerEmbeddedCoder.Sources.FromWorkspace,independentInstance=true,hide=true),Icon(coordinateSystem(extent={{-130,-60},{130,60}},
  grid={2,2}),graphics = {Rectangle(sizePolicy=SizePolicy.Expanding,
  rotationPolicy=RotationPolicy.Follow,
  origin={0,0},
  fillColor={255,255,255},
  fillPattern=FillPattern.Solid,
  lineThickness=3,
  extent={{-130,60},{130,-60}}), Text(origin={0,0},
  lineColor={0,0,0},
  extent={{-120,50},{120,-50}},
  textString="%var_name",
  fontSize=16,
  textStyle={TextStyle.None},
  textColor={0,0,0}), Text(origin={0,-80},
  lineColor={0,0,0},
  extent={{0,-20},{0,20}},
  textString="%name",
  fontSize=14,
  textStyle={TextStyle.None},
  textColor={0,0,0},
  verticalAlignment=TextAlignment.Top)},sizePolicy=SizePolicy.Fixed,rotationPolicy=RotationPolicy.Ignore),Diagram(coordinateSystem(extent={{-100,-100},{100,100}},
  grid={2,2})),Protection(access=Access.packageDuplicate));

      class VarData "外部对象类定义"
        extends ExternalObject;

        function constructor
          input SysplorerEmbeddedCoder.Types.Auto var_name 
            annotation(Placement(transformation(extent={{-15,422},{15,462}})), __MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto dimension 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto target_workspace 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          output VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" obj = __FromWorkspaceInit2(var_name, target_workspace, dimension) annotation(
          Include = "#include \"FromWorkspace.c\"");
        end constructor;

        function destructor
          input VarData obj   annotation(Placement(transformation(extent={{-15,214},{15,254}})));
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __FromWorkspaceDestory(obj) annotation(
          Include = "#include \"FromWorkspace.c\"");
        end destructor;

        annotation(__MWORKS(hide = true),Protection(access=Access.packageDuplicate));
      end VarData;

    block ExternalObject_T "框图外部对象构造模块"
      SysplorerEmbeddedCoder.Types.InputAuto u annotation(
        __MWORKS(HideResult = true, BlockSystem(VariablePort(defaultNumber = 0))));
      SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")), Dimension(dimensionType = DimensionType.none) = 1)));
      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObject)),Protection(access=Access.packageDuplicate));
    end ExternalObject_T;

      parameter SysplorerEmbeddedCoder.Types.Auto var_name = "simin" 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace_hint = -1 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));

    inner ExternalObject_T x "外部对象构造组件" annotation(HideResult = true,
      __MWORKS(BlockSystem(Instance(u(u1(Type(inherit = InheritType.none, ref = "string"),Dimension(dimensionType = DimensionType.none) = 1)="Reflected_Light_Wave_Data",u2(Type(inherit = InheritType.none, ref = "int32"), Dimension(dimensionType = DimensionType.none) = 1) = 1,u3(Type(inherit = InheritType.none, ref = "int32"), Dimension(dimensionType = DimensionType.none) = 1) = target_workspace),y(Type(inherit = InheritType.none, ref = VarData), Dimension(dimensionType = DimensionType.none) = 1)))));

    block ExternalObjectReference "框图外部对象引用模块"
      outer SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")))));  // 外部对象输出

      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObjectReference)),Protection(access=Access.packageDuplicate));
    end ExternalObjectReference;

    ExternalObjectReference extObjRef "外部对象引用组件" annotation(
      __MWORKS(BlockSystem(name = "x")));
    CCaller c_caller 
      annotation(HideResult = true,Placement(transformation(origin={-108.378,5.58745},
  extent={{-103,-50.0583},{103,50.0583}})), __MWORKS(ComponentNamePlacement(BOTTOM)));
    SysplorerEmbeddedCoder.Port.Outport outport 
      annotation(Placement(transformation(origin = {38, -19.4417},
      extent = {{-10, -10}, {10, 10}}),
      iconTransformation(origin = {101.8, 0},
      extent = {{-1.8, -1.8}, {1.8, 1.8}})));
    SysplorerEmbeddedCoder.Sources.DigitalClock digitalClock 
      annotation (Placement(transformation(origin = {-270, -20}, extent = {{-15, -9}, {18, 10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=-1)));
    block CCaller

        annotation(
         __MWORKS(PortArrangement(Left(p,in_time), Right(out,data_output)),PortLabels(labelType="CustomType",labels(label(text="p",instance="p"),label(text="in_time",instance="in_time"),label(text="out",instance="out"),label(text="data_output",instance="data_output"))), BlockSystem(blockKind = BlockKind.atomic, bltBlockKind = BltBlockKind.ccaller), independentInstance = true, sourceModel = SysplorerEmbeddedCoder.Utilities.CCaller, ExternalFunctionBlock, hide = true),
              Icon(coordinateSystem(extent = { {-200.0, -100.0}, {200.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 }), graphics = { Rectangle(origin = {0.0, 0.0},
              fillColor = {255, 255, 255},
              fillPattern = FillPattern.Solid,
              extent = {{-200.0, 100.0}, {200.0, -100.0}}), Text(origin = {0.0, 0.0},
              extent = {{-100.0, 20.0}, {100, -20}},
              textString = "__FromWorkspace",
              verticalAlignment = TextAlignment.VCenter), Text(origin = {0.0, -120.0},
              lineColor = {0, 0, 0},
              extent = {{-150, 20}, {150, -20}},
              textString = "%name",
              fontSize = 14,
             textStyle = {TextStyle.None},
              textColor = {0, 0, 0},
              verticalAlignment = TextAlignment.Top) }),
          Diagram(coordinateSystem(extent = { {-100.0, -100.0}, {100.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 })),Protection(access=Access.packageDuplicate));
      function func_CCaller
      output SysplorerEmbeddedCoder.Types.Auto out annotation(Placement(transformation(extent={{-15,6},{15,46}})), __MWORKS(BlockSystem(Type(inherit = InheritType.none, ref="int32"), Dimension(dimensionType = DimensionType.none) = 1)));
      input SysplorerEmbeddedCoder.Types.Auto p annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref=VarData), Dimension(dimensionType = DimensionType.none) = 1)));
      input SysplorerEmbeddedCoder.Types.Auto in_time annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref="double"), Dimension(dimensionType = DimensionType.none) = 1)));
      output SysplorerEmbeddedCoder.Types.Auto data_output annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref="double"), Dimension(dimensionType = DimensionType.none) = 1)));
        annotation(Protection(access=Access.packageDuplicate));
    external "C" out=__FromWorkspace(p,in_time,data_output) 
    annotation (__MWORKS(BlockSystem(functionProto = "int __FromWorkspace(void* p,double in_time,double* data_output)")),Include = "#include \"FromWorkspace.c\"",
      IncludeDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Include/Workspace",
      Library = "syslab_workspace_operator",
      LibraryDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Library");
    end func_CCaller;
        SysplorerEmbeddedCoder.Port.Inport p 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport in_time 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Outport out 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Outport data_output 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
      equation

      (out, data_output) = func_CCaller(p, in_time);
    end CCaller;
  equation
    connect(extObjRef.y, c_caller.p);
    connect(c_caller.data_output, outport) 
      annotation(Line(origin={-33,-19},
  points={{29.422,-0.4417},{59,-0.4417}},
  color={0,0,0}));
    connect(digitalClock.y, c_caller.in_time) 
    annotation(Line(origin={-237,-21},
  points={{-13.2,1.5},{23.822,1.5583}},
  color={0,0,0}));
  end FromWorkspace;
  block ToWorkspace "以数组的形式向Syslab工作区写入数据"
    annotation(defaultComponentName = "toWorkspace", __MWORKS(PortArrangement(Left(inport)),BlockSystem(blockKind=Types.BlockKind.composite, bltBlockKind=Types.BltBlockKind.toWorkspace),sourceModel=SysplorerEmbeddedCoder.Utilities.ToWorkspace,independentInstance=true,hide=true),Icon(coordinateSystem(extent={{-130,-60},{130,60}},
  grid={2,2}),graphics = {Rectangle(sizePolicy=SizePolicy.Expanding,
  rotationPolicy=RotationPolicy.Follow,
  origin={0,0},
  fillColor={255,255,255},
  fillPattern=FillPattern.Solid,
  lineThickness=3,
  extent={{-130,60},{130,-60}}), Text(origin={0,0},
  lineColor={0,0,0},
  extent={{-120,50},{120,-50}},
  textString="%var_name",
  fontSize=16,
  textStyle={TextStyle.None},
  textColor={0,0,0}), Text(origin={0,-80},
  lineColor={0,0,0},
  extent={{0,-20},{0,20}},
  textString="%name",
  fontSize=14,
  textStyle={TextStyle.None},
  textColor={0,0,0},
  verticalAlignment=TextAlignment.Top)},sizePolicy=SizePolicy.Fixed,rotationPolicy=RotationPolicy.Ignore),Diagram(coordinateSystem(extent={{-100,-100},{100,100}},
  grid={2,2})),Protection(access=Access.packageDuplicate));

      class VarData "外部对象类定义"
        extends ExternalObject;

        function constructor
          input SysplorerEmbeddedCoder.Types.Auto var_name 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto dimension 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto extract_size 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto target_workspace 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto max_data_point 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          output VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" obj = __ToWorkspaceInit2(var_name, target_workspace, dimension, extract_size, max_data_point) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end constructor;

        function terminator
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceTerminate(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end terminator;

        function destructor
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceDestory(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end destructor;
        annotation(__MWORKS(hide = true),Protection(access=Access.packageDuplicate));
      end VarData;


    block ExternalObject_T "框图外部对象构造模块"
      SysplorerEmbeddedCoder.Types.InputAuto u annotation(
        __MWORKS(HideResult = true, BlockSystem(VariablePort(defaultNumber = 0))));
      SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")), Dimension(dimensionType = DimensionType.none) = 1)));
      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObject)),Protection(access=Access.packageDuplicate));
    end ExternalObject_T;

      parameter SysplorerEmbeddedCoder.Types.Auto var_name = "simout" 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto extract = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace_hint = -1 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto max_data_point = 2147483647 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));

    inner ExternalObject_T x "外部对象构造组件" annotation(HideResult = true,
      __MWORKS(BlockSystem(Instance(u(u1(Type(inherit=InheritType.none ,ref="string") ,Dimension(dimensionType=DimensionType.none)=1)="simout",u2(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=size(reshape.y,1),u3(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=0,u4(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=target_workspace,u5(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=max_data_point),y(Type(inherit=InheritType.none ,ref=VarData) ,Dimension(dimensionType=DimensionType.none)=1)))));

    block ExternalObjectReference "框图外部对象引用模块"
      outer SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")))));  // 外部对象输出

      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObjectReference)),Protection(access=Access.packageDuplicate));
    end ExternalObjectReference;

    ExternalObjectReference extObjRef "外部对象引用组件" annotation(
      __MWORKS(HideResult = true,BlockSystem(name = "x")));
    CCaller c_caller 
      annotation(HideResult = true,Placement(transformation(origin={37.5,-36.5221},
  extent={{-121.5,-73.5334},{121.5,73.5334}})),__MWORKS(ComponentNamePlacement(BOTTOM)));
    SysplorerEmbeddedCoder.Port.Inport inport 
      annotation (Placement(transformation(origin={-229.818,-36.1558},
  extent={{-10,-10},{10,10}}),
  iconTransformation(origin={-101.8,0},
  extent={{-1.8,-1.8},{1.8,1.8}})),__MWORKS(BlockSystem(AllowDimension(choices(choice = Types.DimensionType.scalar, choice = Types.DimensionType.array1D, choice = Types.DimensionType.columnVector2D, choice = Types.DimensionType.rowVector2D)))));
    SysplorerEmbeddedCoder.MathOperation.Reshape reshape 
      annotation (HideResult = true,Placement(transformation(origin={-153,-36.5221},
  extent={{-10,-10},{10,10}})));
    SysplorerEmbeddedCoder.Sources.DigitalClock digitalClock 
      annotation (Placement(transformation(origin={-231.318,-86.0444},
  extent={{-15,-9},{18,10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=-1)));
    block CCaller

        annotation(
         __MWORKS(PortArrangement(Left(p,data_input,in_time), Right(out)),PortLabels(labelType="CustomType",labels(label(text="p",instance="p"),label(text="data_input",instance="data_input"),label(text="in_time",instance="in_time"),label(text="out",instance="out"))),BlockSystem(blockKind = BlockKind.atomic,bltBlockKind = BltBlockKind.ccaller),independentInstance = true,sourceModel = SysplorerEmbeddedCoder.Utilities.CCaller,ExternalFunctionBlock,hide = true),
              Icon(coordinateSystem(extent = { {-200.0, -100.0}, {200.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 }), graphics = { Rectangle(origin = {0.0, 0.0},
              fillColor = {255, 255, 255},
              fillPattern = FillPattern.Solid,
              extent = {{-200.0, 100.0}, {200.0, -100.0}}), Text(origin = {0.0, 0.0},
              extent = {{-200.0, 20.0}, {200, -20}},
              textString = "__ToWorkspaceStep",
              verticalAlignment = TextAlignment.VCenter), Text(origin = {0.0, -120.0},
              lineColor = {0, 0, 0},
              extent = {{-150, 20}, {150, -20}},
              textString = "%name",
              fontSize = 14,
             textStyle = {TextStyle.None},
              textColor = {0, 0, 0},
              verticalAlignment = TextAlignment.Top) }),
          Diagram(coordinateSystem(extent = { {-100.0, -100.0}, {100.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 })),Protection(access=Access.packageDuplicate));
      function func_CCaller
          output SysplorerEmbeddedCoder.Types.Auto out annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto p annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto data_input[:] annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double")/*, Dimension(dimensionType = DimensionType.none) = [3]*/)));
          input SysplorerEmbeddedCoder.Types.Auto in_time annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"), Dimension(dimensionType = DimensionType.none) = 1)));
          external "C" out =__ToWorkspaceStep(p, data_input, in_time) 
              annotation(Include = "#include \"ToWorkspace.c\"",
                  IncludeDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Include/Workspace",
                  Library = "syslab_workspace_operator",
                  LibraryDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Library");
              end func_CCaller;
        SysplorerEmbeddedCoder.Port.Inport p 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport data_input 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.auto, ref = "double"),Dimension(dimensionType = DimensionType.auto) = -1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport in_time 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Outport out 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
      equation

      out = func_CCaller(p, data_input, in_time);
    end CCaller;
    equation
    connect(extObjRef.y, c_caller.p);
    connect(c_caller.in_time, digitalClock.y) 
      annotation(Line(origin={-101,-47},
  points={{15.2,-38.5444},{-110.518,-38.5444}},
  color={0,0,0}));
    connect(inport, reshape.u1) 
    annotation(Line(origin={-135,-37},
  points={{-82.8183,0.844205},{-29.8,0.844205},{-29.8,0.4779}},
  color={0,0,0}));
    connect(reshape.y, c_caller.data_input) 
    annotation(Line(origin={-127,-37},
  points={{-14.2,0.4779},{41.2,0.4779}},
  color={0,0,0}));
    end ToWorkspace;
  block ToWorkspace1 "以数组的形式向Syslab工作区写入数据"
    annotation(defaultComponentName = "toWorkspace", __MWORKS(PortArrangement(Left(inport)),BlockSystem(blockKind=Types.BlockKind.composite, bltBlockKind=Types.BltBlockKind.toWorkspace),sourceModel=SysplorerEmbeddedCoder.Utilities.ToWorkspace,independentInstance=true,hide=true),Icon(coordinateSystem(extent={{-130,-60},{130,60}},
  grid={2,2}),graphics = {Rectangle(sizePolicy=SizePolicy.Expanding,
  rotationPolicy=RotationPolicy.Follow,
  origin={0,0},
  fillColor={255,255,255},
  fillPattern=FillPattern.Solid,
  lineThickness=3,
  extent={{-130,60},{130,-60}}), Text(origin={0,0},
  lineColor={0,0,0},
  extent={{-120,50},{120,-50}},
  textString="%var_name",
  fontSize=16,
  textStyle={TextStyle.None},
  textColor={0,0,0}), Text(origin={0,-80},
  lineColor={0,0,0},
  extent={{0,-20},{0,20}},
  textString="%name",
  fontSize=14,
  textStyle={TextStyle.None},
  textColor={0,0,0},
  verticalAlignment=TextAlignment.Top)},sizePolicy=SizePolicy.Fixed,rotationPolicy=RotationPolicy.Ignore),Diagram(coordinateSystem(extent={{-100,-100},{100,100}},
  grid={2,2})),Protection(access=Access.packageDuplicate));

      class VarData "外部对象类定义"
        extends ExternalObject;

        function constructor
          input SysplorerEmbeddedCoder.Types.Auto var_name 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto dimension 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto extract_size 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto target_workspace 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto max_data_point 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          output VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" obj = __ToWorkspaceInit2(var_name, target_workspace, dimension, extract_size, max_data_point) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end constructor;

        function terminator
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceTerminate(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end terminator;

        function destructor
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceDestory(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end destructor;
        annotation(__MWORKS(hide = true),Protection(access=Access.packageDuplicate));
      end VarData;


    block ExternalObject_T "框图外部对象构造模块"
      SysplorerEmbeddedCoder.Types.InputAuto u annotation(
        __MWORKS(HideResult = true, BlockSystem(VariablePort(defaultNumber = 0))));
      SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")), Dimension(dimensionType = DimensionType.none) = 1)));
      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObject)),Protection(access=Access.packageDuplicate));
    end ExternalObject_T;

      parameter SysplorerEmbeddedCoder.Types.Auto var_name = "simout" 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto extract = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace_hint = -1 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto max_data_point = 2147483647 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));

    inner ExternalObject_T x "外部对象构造组件" annotation(HideResult = true,
      __MWORKS(BlockSystem(Instance(u(u1(Type(inherit=InheritType.none ,ref="string") ,Dimension(dimensionType=DimensionType.none)=1)="Heterodyne",u2(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=size(reshape.y,1),u3(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=0,u4(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=target_workspace,u5(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=max_data_point),y(Type(inherit=InheritType.none ,ref=VarData) ,Dimension(dimensionType=DimensionType.none)=1)))));

    block ExternalObjectReference "框图外部对象引用模块"
      outer SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")))));  // 外部对象输出

      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObjectReference)),Protection(access=Access.packageDuplicate));
    end ExternalObjectReference;

    ExternalObjectReference extObjRef "外部对象引用组件" annotation(
      __MWORKS(HideResult = true,BlockSystem(name = "x")));
    CCaller c_caller 
      annotation(HideResult = true,Placement(transformation(origin={37.5,-36.5221},
  extent={{-121.5,-73.5334},{121.5,73.5334}})),__MWORKS(ComponentNamePlacement(BOTTOM)));
    SysplorerEmbeddedCoder.Port.Inport inport 
      annotation (Placement(transformation(origin={-229.818,-36.1558},
  extent={{-10,-10},{10,10}}),
  iconTransformation(origin={-101.8,0},
  extent={{-1.8,-1.8},{1.8,1.8}})),__MWORKS(BlockSystem(AllowDimension(choices(choice = Types.DimensionType.scalar, choice = Types.DimensionType.array1D, choice = Types.DimensionType.columnVector2D, choice = Types.DimensionType.rowVector2D)))));
    SysplorerEmbeddedCoder.MathOperation.Reshape reshape 
      annotation (HideResult = true,Placement(transformation(origin={-153,-36.5221},
  extent={{-10,-10},{10,10}})));
    SysplorerEmbeddedCoder.Sources.DigitalClock digitalClock 
      annotation (Placement(transformation(origin={-231.318,-86.0444},
  extent={{-15,-9},{18,10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=-1)));
    block CCaller

        annotation(
         __MWORKS(PortArrangement(Left(p,data_input,in_time), Right(out)),PortLabels(labelType="CustomType",labels(label(text="p",instance="p"),label(text="data_input",instance="data_input"),label(text="in_time",instance="in_time"),label(text="out",instance="out"))),BlockSystem(blockKind = BlockKind.atomic,bltBlockKind = BltBlockKind.ccaller),independentInstance = true,sourceModel = SysplorerEmbeddedCoder.Utilities.CCaller,ExternalFunctionBlock,hide = true),
              Icon(coordinateSystem(extent = { {-200.0, -100.0}, {200.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 }), graphics = { Rectangle(origin = {0.0, 0.0},
              fillColor = {255, 255, 255},
              fillPattern = FillPattern.Solid,
              extent = {{-200.0, 100.0}, {200.0, -100.0}}), Text(origin = {0.0, 0.0},
              extent = {{-200.0, 20.0}, {200, -20}},
              textString = "__ToWorkspaceStep",
              verticalAlignment = TextAlignment.VCenter), Text(origin = {0.0, -120.0},
              lineColor = {0, 0, 0},
              extent = {{-150, 20}, {150, -20}},
              textString = "%name",
              fontSize = 14,
             textStyle = {TextStyle.None},
              textColor = {0, 0, 0},
              verticalAlignment = TextAlignment.Top) }),
          Diagram(coordinateSystem(extent = { {-100.0, -100.0}, {100.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 })),Protection(access=Access.packageDuplicate));
      function func_CCaller
          output SysplorerEmbeddedCoder.Types.Auto out annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto p annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto data_input[:] annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double")/*, Dimension(dimensionType = DimensionType.none) = [3]*/)));
          input SysplorerEmbeddedCoder.Types.Auto in_time annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"), Dimension(dimensionType = DimensionType.none) = 1)));
          external "C" out =__ToWorkspaceStep(p, data_input, in_time) 
              annotation(Include = "#include \"ToWorkspace.c\"",
                  IncludeDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Include/Workspace",
                  Library = "syslab_workspace_operator",
                  LibraryDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Library");
              end func_CCaller;
        SysplorerEmbeddedCoder.Port.Inport p 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport data_input 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.auto, ref = "double"),Dimension(dimensionType = DimensionType.auto) = -1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport in_time 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Outport out 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
      equation

      out = func_CCaller(p, data_input, in_time);
    end CCaller;
    equation
    connect(extObjRef.y, c_caller.p);
    connect(c_caller.in_time, digitalClock.y) 
      annotation(Line(origin={-101,-47},
  points={{15.2,-38.5444},{-110.518,-38.5444}},
  color={0,0,0}));
    connect(inport, reshape.u1) 
    annotation(Line(origin={-135,-37},
  points={{-82.8183,0.844205},{-29.8,0.844205},{-29.8,0.4779}},
  color={0,0,0}));
    connect(reshape.y, c_caller.data_input) 
    annotation(Line(origin={-127,-37},
  points={{-14.2,0.4779},{41.2,0.4779}},
  color={0,0,0}));
    end ToWorkspace1;
  block ToWorkspace2 "以数组的形式向Syslab工作区写入数据"
    annotation(defaultComponentName = "toWorkspace", __MWORKS(PortArrangement(Left(inport)),BlockSystem(blockKind=Types.BlockKind.composite, bltBlockKind=Types.BltBlockKind.toWorkspace),sourceModel=SysplorerEmbeddedCoder.Utilities.ToWorkspace,independentInstance=true,hide=true),Icon(coordinateSystem(extent={{-130,-60},{130,60}},
  grid={2,2}),graphics = {Rectangle(sizePolicy=SizePolicy.Expanding,
  rotationPolicy=RotationPolicy.Follow,
  origin={0,0},
  fillColor={255,255,255},
  fillPattern=FillPattern.Solid,
  lineThickness=3,
  extent={{-130,60},{130,-60}}), Text(origin={0,0},
  lineColor={0,0,0},
  extent={{-120,50},{120,-50}},
  textString="%var_name",
  fontSize=16,
  textStyle={TextStyle.None},
  textColor={0,0,0}), Text(origin={0,-80},
  lineColor={0,0,0},
  extent={{0,-20},{0,20}},
  textString="%name",
  fontSize=14,
  textStyle={TextStyle.None},
  textColor={0,0,0},
  verticalAlignment=TextAlignment.Top)},sizePolicy=SizePolicy.Fixed,rotationPolicy=RotationPolicy.Ignore),Diagram(coordinateSystem(extent={{-100,-100},{100,100}},
  grid={2,2})),Protection(access=Access.packageDuplicate));

      class VarData "外部对象类定义"
        extends ExternalObject;

        function constructor
          input SysplorerEmbeddedCoder.Types.Auto var_name 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto dimension 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto extract_size 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto target_workspace 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto max_data_point 
            annotation(__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
          output VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" obj = __ToWorkspaceInit2(var_name, target_workspace, dimension, extract_size, max_data_point) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end constructor;

        function terminator
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceTerminate(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end terminator;

        function destructor
          input VarData obj;
          annotation(Protection(access=Access.packageDuplicate));
        external "C" __ToWorkspaceDestory(obj) annotation(
          Include = "#include \"ToWorkspace.c\"");
        end destructor;
        annotation(__MWORKS(hide = true),Protection(access=Access.packageDuplicate));
      end VarData;


    block ExternalObject_T "框图外部对象构造模块"
      SysplorerEmbeddedCoder.Types.InputAuto u annotation(
        __MWORKS(HideResult = true, BlockSystem(VariablePort(defaultNumber = 0))));
      SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")), Dimension(dimensionType = DimensionType.none) = 1)));
      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObject)),Protection(access=Access.packageDuplicate));
    end ExternalObject_T;

      parameter SysplorerEmbeddedCoder.Types.Auto var_name = "simout" 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "string"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto extract = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace_hint = -1 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto target_workspace = 0 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));
      parameter SysplorerEmbeddedCoder.Types.Auto max_data_point = 2147483647 
            annotation(HideResult = true,__MWORKS(BlockSystem(
            Type(inherit = InheritType.none, ref = "int32"),
            Dimension(dimensionType = DimensionType.none) = 1)));

    inner ExternalObject_T x "外部对象构造组件" annotation(HideResult = true,
      __MWORKS(BlockSystem(Instance(u(u1(Type(inherit=InheritType.none ,ref="string") ,Dimension(dimensionType=DimensionType.none)=1)="Homodyne",u2(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=size(reshape.y,1),u3(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=0,u4(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=target_workspace,u5(Type(inherit=InheritType.none ,ref="int32") ,Dimension(dimensionType=DimensionType.none)=1)=max_data_point),y(Type(inherit=InheritType.none ,ref=VarData) ,Dimension(dimensionType=DimensionType.none)=1)))));

    block ExternalObjectReference "框图外部对象引用模块"
      outer SysplorerEmbeddedCoder.Types.OutputAuto y annotation(
        __MWORKS(BlockSystem(AllowType(choices(choice = "extobj")))));  // 外部对象输出

      annotation(__MWORKS(hide = true, BlockSystem(blockKind = Types.BlockKind.atomic,
        bltBlockKind = Types.BltBlockKind.externalObjectReference)),Protection(access=Access.packageDuplicate));
    end ExternalObjectReference;

    ExternalObjectReference extObjRef "外部对象引用组件" annotation(
      __MWORKS(HideResult = true,BlockSystem(name = "x")));
    CCaller c_caller 
      annotation(HideResult = true,Placement(transformation(origin={37.5,-36.5221},
  extent={{-121.5,-73.5334},{121.5,73.5334}})),__MWORKS(ComponentNamePlacement(BOTTOM)));
    SysplorerEmbeddedCoder.Port.Inport inport 
      annotation (Placement(transformation(origin={-229.818,-36.1558},
  extent={{-10,-10},{10,10}}),
  iconTransformation(origin={-101.8,0},
  extent={{-1.8,-1.8},{1.8,1.8}})),__MWORKS(BlockSystem(AllowDimension(choices(choice = Types.DimensionType.scalar, choice = Types.DimensionType.array1D, choice = Types.DimensionType.columnVector2D, choice = Types.DimensionType.rowVector2D)))));
    SysplorerEmbeddedCoder.MathOperation.Reshape reshape 
      annotation (HideResult = true,Placement(transformation(origin={-153,-36.5221},
  extent={{-10,-10},{10,10}})));
    SysplorerEmbeddedCoder.Sources.DigitalClock digitalClock 
      annotation (Placement(transformation(origin={-231.318,-86.0444},
  extent={{-15,-9},{18,10}})),__MWORKS(BlockSystem(SampleTime(auto=false)=-1)));
    block CCaller

        annotation(
         __MWORKS(PortArrangement(Left(p,data_input,in_time), Right(out)),PortLabels(labelType="CustomType",labels(label(text="p",instance="p"),label(text="data_input",instance="data_input"),label(text="in_time",instance="in_time"),label(text="out",instance="out"))),BlockSystem(blockKind = BlockKind.atomic,bltBlockKind = BltBlockKind.ccaller),independentInstance = true,sourceModel = SysplorerEmbeddedCoder.Utilities.CCaller,ExternalFunctionBlock,hide = true),
              Icon(coordinateSystem(extent = { {-200.0, -100.0}, {200.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 }), graphics = { Rectangle(origin = {0.0, 0.0},
              fillColor = {255, 255, 255},
              fillPattern = FillPattern.Solid,
              extent = {{-200.0, 100.0}, {200.0, -100.0}}), Text(origin = {0.0, 0.0},
              extent = {{-200.0, 20.0}, {200, -20}},
              textString = "__ToWorkspaceStep",
              verticalAlignment = TextAlignment.VCenter), Text(origin = {0.0, -120.0},
              lineColor = {0, 0, 0},
              extent = {{-150, 20}, {150, -20}},
              textString = "%name",
              fontSize = 14,
             textStyle = {TextStyle.None},
              textColor = {0, 0, 0},
              verticalAlignment = TextAlignment.Top) }),
          Diagram(coordinateSystem(extent = { {-100.0, -100.0}, {100.0, 100.0} },
              preserveAspectRatio = false,
              initialScale = 0.1,
              grid = { 2.0, 2.0 })),Protection(access=Access.packageDuplicate));
      function func_CCaller
          output SysplorerEmbeddedCoder.Types.Auto out annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto p annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData), Dimension(dimensionType = DimensionType.none) = 1)));
          input SysplorerEmbeddedCoder.Types.Auto data_input[:] annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double")/*, Dimension(dimensionType = DimensionType.none) = [3]*/)));
          input SysplorerEmbeddedCoder.Types.Auto in_time annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"), Dimension(dimensionType = DimensionType.none) = 1)));
          external "C" out =__ToWorkspaceStep(p, data_input, in_time) 
              annotation(Include = "#include \"ToWorkspace.c\"",
                  IncludeDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Include/Workspace",
                  Library = "syslab_workspace_operator",
                  LibraryDirectory = "modelica://SysplorerEmbeddedCoder/Resources/Library");
              end func_CCaller;
        SysplorerEmbeddedCoder.Port.Inport p 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = VarData),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport data_input 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.auto, ref = "double"),Dimension(dimensionType = DimensionType.auto) = -1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Inport in_time 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "double"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
        SysplorerEmbeddedCoder.Port.Outport out 
        annotation(__MWORKS(BlockSystem(Type(inherit = InheritType.none, ref = "int32"),Dimension(dimensionType = DimensionType.none) = 1)), Placement(transformation(origin = {0,0}, extent = { {-10,-10}, {10,10} })));
      equation

      out = func_CCaller(p, data_input, in_time);
    end CCaller;
    equation
    connect(extObjRef.y, c_caller.p);
    connect(c_caller.in_time, digitalClock.y) 
      annotation(Line(origin={-101,-47},
  points={{15.2,-38.5444},{-110.518,-38.5444}},
  color={0,0,0}));
    connect(inport, reshape.u1) 
    annotation(Line(origin={-135,-37},
  points={{-82.8183,0.844205},{-29.8,0.844205},{-29.8,0.4779}},
  color={0,0,0}));
    connect(reshape.y, c_caller.data_input) 
    annotation(Line(origin={-127,-37},
  points={{-14.2,0.4779},{41.2,0.4779}},
  color={0,0,0}));
    end ToWorkspace2;
equation
  connect(Product.y, Integrator.u1) 
  annotation(Line(origin={0,0},
  points={{-26,74},{-26,72},{-22,72}}));
  connect(Product1.y, Integrator1.u1) 
  annotation(Line(origin={0,0},
  points={{-26,33},{-26,31},{-22,31}}));
  connect(Integrator1.y, Subtract.u2) 
  annotation(Line(origin={0,0},
  points={{8,31},{19,31},{19,44},{19,45},{29,45}}));
  connect(Integrator.y, Subtract.u1) 
  annotation(Line(origin={0,0},
  points={{8,72},{16,72},{16,55},{29,55}}));
  connect(Product3.y, Integrator3.u1) 
  annotation(Line(origin={0,0},
  points={{-26,-75},{-26,-78},{-22,-78}}));
  connect(Integrator2.y, Subtract1.u1) 
  annotation(Line(origin={0,0},
  points={{8,-37},{16,-37},{16,-50},{29,-50}}));
  connect(Product2.y, Integrator2.u1) 
  annotation(Line(origin={0,0},
  points={{-26,-35},{-26,-37},{-22,-37}}));
  connect(Integrator3.y, Subtract1.u2) 
  annotation(Line(origin={0,0},
  points={{8,-78},{16,-78},{16,-61},{16,-60},{29,-60}}));
  connect(Subtract.y, 'To Workspace2'.inport) 
  annotation(Line(origin={0,0},
  points={{59,50},{68,50},{68,48},{131,48}}));
  connect(Subtract.y, Divide.u1) 
  annotation(Line(origin={0,0},
  points={{59,50},{68,50},{68,3},{68,1},{90,1}}));
  connect(Subtract1.y, 'To Workspace1'.inport) 
  annotation(Line(origin={0,0},
  points={{59,-55},{69,-55},{69,-57},{131,-57}}));
  connect(Subtract1.y, Divide.u2) 
  annotation(Line(origin={0,0},
  points={{59,-55},{69,-55},{69,-8},{69,-9},{90,-9}}));
  connect(Divide.y, 'To Workspace'.inport) 
  annotation(Line(origin={0,0},
  points={{120,-4},{120,-6},{131,-6}}));
  connect('Pulse10Generator9'.y, Product.u1) 
  annotation(Line(origin={0,0},
  points={{-91,80},{-91,79},{-56,79}}));
  connect('Pulse10Generator6'.y, Product2.u1) 
  annotation(Line(origin={0,0},
  points={{-91,-29},{-91,-30},{-56,-30}}));
  connect('Pulse10Generator7'.y, Product3.u1) 
  annotation(Line(origin={0,0},
  points={{-91,-70},{-56,-70}}));
  connect('Pulse10Generator8'.y, Product1.u1) 
  annotation(Line(origin={0,0},
  points={{-91,39},{-91,38},{-56,38}}));
  connect('From10Workspace2'.outport, Product.u2) 
  annotation(Line(origin={0,0},
  points={{-119,1},{-73,1},{-73,28},{-73,68},{-73,69},{-56,69}}));
  connect('From10Workspace2'.outport, Product1.u2) 
  annotation(Line(origin={0,0},
  points={{-119,1},{-73,1},{-73,28},{-56,28}}));
  connect('From10Workspace2'.outport, Product3.u2) 
  annotation(Line(origin={0,0},
  points={{-119,1},{-73,1},{-73,-39},{-73,-79},{-73,-80},{-56,-80}}));
  connect('From10Workspace2'.outport, Product2.u2) 
  annotation(Line(origin={0,0},
  points={{-119,1},{-73,1},{-73,-39},{-73,-40},{-56,-40}}));

end Do_tof;