// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RRF_HumanShaders/HairShader2/HairShader2_AS_RRF_VRTC"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Light_Bias("Light_Bias", Range( 0 , 0.1)) = 0
		_Light_Scale("Light_Scale", Range( 0 , 10)) = 0
		_LightScatter("LightScatter", Range( 0 , 1)) = 0
		_BaseIllumination("BaseIllumination", Range( 0 , 1)) = 0.15
		_SSS("SSS", Range( 0 , 1)) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Alpha_Level("Alpha_Level", Range( 0 , 2)) = 1
		_VRTC("VRTC", 2D) = "white" {}
		[Toggle(_USEVRTC_BIASANDSCALE_ON)] _UseVRTC_BiasAndScale("UseVRTC_BiasAndScale?", Float) = 0
		_VRTC_Bias("VRTC_Bias", Range( 0 , 1)) = 0
		_VRTC_Scale("VRTC_Scale", Range( 0 , 4)) = 1
		_VariantColor1_GlossA("VariantColor1_Gloss(A)", Color) = (0.8897059,0.1308391,0.1308391,0.516)
		_Variant_Color2_GlossA("Variant_Color2_Gloss(A)", Color) = (0,0.1356491,0.7867647,0.516)
		_RootColorPowerA("RootColor-Power(A)", Color) = (0.1102941,0.1005623,0.1005623,0.453)
		_TipColorPowerA("TipColor-Power(A)", Color) = (0.9448277,1,0,0.484)
		_BumpPower("BumpPower", Range( 0 , 5)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_MainHighlight_Color("MainHighlight_Color", Color) = (0,0,0,0)
		_MainHighlightPosition("Main Highlight Position", Range( -1 , 3)) = 0
		_MainHighlightStrength("Main Highlight Strength", Range( 0 , 2)) = 0.25
		_MainHighlightExponent("Main Highlight Exponent", Range( 0 , 1000)) = 0.2
		_SecondaryHighlightColor("Secondary Highlight Color", Color) = (0.8862069,0.8862069,0.8862069,0)
		_SecondaryHighlightPosition("Secondary Highlight Position", Range( -1 , 3)) = 0
		_SecondaryHighlightStrength("Secondary Highlight Strength", Range( 0 , 2)) = 0.25
		_SecondaryHighlightExponent("Secondary Highlight Exponent", Range( 0 , 1000)) = 0.2
		_Spread("Spread", Range( 0 , 3)) = 0
		_NoisePower("NoisePower", Range( 0 , 2000)) = 0
		_ExtraCuttingR("ExtraCutting(R)", 2D) = "white" {}
		_Stretch("Stretch", Range( 0.01 , 1.01)) = 0.4961396
		_XTiling("XTiling", Range( 1 , 8)) = 0
		_PushHairs("PushHairs", Range( 0 , 1)) = 0
		_PushHairs_Bias("PushHairs_Bias", Range( 1 , 10)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		ZTest Less
		Offset  1 , 5
		AlphaToMask On
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma shader_feature _USEVRTC_BIASANDSCALE_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform float _PushHairs;
		uniform float _PushHairs_Bias;
		uniform float _BumpPower;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _VariantColor1_GlossA;
		uniform float4 _Variant_Color2_GlossA;
		uniform sampler2D _VRTC;
		uniform float4 _VRTC_ST;
		uniform float _VRTC_Bias;
		uniform float _VRTC_Scale;
		uniform float4 _RootColorPowerA;
		uniform float4 _TipColorPowerA;
		uniform float4 _MainHighlight_Color;
		uniform float _MainHighlightPosition;
		uniform float _Spread;
		uniform float _NoisePower;
		uniform float _MainHighlightExponent;
		uniform float _MainHighlightStrength;
		uniform float _SecondaryHighlightPosition;
		uniform float _SecondaryHighlightExponent;
		uniform float _SecondaryHighlightStrength;
		uniform float4 _SecondaryHighlightColor;
		uniform float _BaseIllumination;
		uniform float _SSS;
		uniform float _Light_Bias;
		uniform float _Light_Scale;
		uniform float _LightScatter;
		uniform float _Metallic;
		uniform float _Alpha_Level;
		uniform sampler2D _ExtraCuttingR;
		uniform float _XTiling;
		uniform float _Stretch;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 OUTPUT_VertexMotion423 = ( ( _PushHairs * pow( ( 1.0 - v.texcoord.xy.y ) , _PushHairs_Bias ) * ase_vertexNormal ) + ase_vertex3Pos );
			v.vertex.xyz = OUTPUT_VertexMotion423;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _BumpPower );
			float3 OUTPUT_NormalMap410 = tex2DNode7;
			o.Normal = OUTPUT_NormalMap410;
			float2 uv_VRTC = i.uv_texcoord * _VRTC_ST.xy + _VRTC_ST.zw;
			float4 tex2DNode335 = tex2D( _VRTC, uv_VRTC );
			#ifdef _USEVRTC_BIASANDSCALE_ON
				float4 staticSwitch373 = ( ( tex2DNode335 + _VRTC_Bias ) * _VRTC_Scale );
			#else
				float4 staticSwitch373 = tex2DNode335;
			#endif
			float4 break372 = staticSwitch373;
			float4 lerpResult328 = lerp( _VariantColor1_GlossA , _Variant_Color2_GlossA , break372.r);
			float4 lerpResult330 = lerp( lerpResult328 , _RootColorPowerA , ( _RootColorPowerA.a * break372.g ));
			float4 lerpResult332 = lerp( lerpResult330 , _TipColorPowerA , ( _TipColorPowerA.a * break372.b ));
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 T200 = cross( ase_worldTangent , ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float originalAlphaCutout403 = tex2DNode335.a;
			float2 appendResult365 = (float2(_NoisePower , 0.1));
			float2 uv_TexCoord316 = i.uv_texcoord * appendResult365;
			float simplePerlin2D315 = snoise( uv_TexCoord316 );
			float NoiseFX312 = ( ( tex2DNode7.g + _Spread ) * ( originalAlphaCutout403 * simplePerlin2D315 ) * _Spread );
			float4 appendResult305 = (float4(ase_worldlightDir.x , ( ( _MainHighlightPosition + NoiseFX312 ) + ase_worldlightDir.y ) , ase_worldlightDir.z , 0.0));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float4 normalizeResult78 = normalize( ( appendResult305 + float4( ase_worldViewDir , 0.0 ) ) );
			float4 H93 = normalizeResult78;
			float dotResult95 = dot( float4( T200 , 0.0 ) , H93 );
			float dotTH94 = dotResult95;
			float sinTH97 = sqrt( ( 1.0 - ( dotTH94 * dotTH94 ) ) );
			float smoothstepResult103 = smoothstep( -1.0 , 0.0 , dotTH94);
			float dirAtten102 = smoothstepResult103;
			float dotResult279 = dot( ase_worldlightDir , ase_worldNormal );
			float clampResult290 = clamp( ( dotResult279 * dotResult279 * dotResult279 ) , 0.0 , 1.0 );
			float lightZone285 = clampResult290;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_268_0 = ( _MainHighlight_Color * ( pow( sinTH97 , _MainHighlightExponent ) * _MainHighlightStrength * dirAtten102 * lightZone285 ) * ase_lightColor * ase_lightColor.a );
			float4 appendResult241 = (float4(ase_worldlightDir.x , ( ( _SecondaryHighlightPosition + NoiseFX312 ) + ase_worldlightDir.y ) , ase_worldlightDir.z , 0.0));
			float4 normalizeResult246 = normalize( ( appendResult241 + float4( ase_worldViewDir , 0.0 ) ) );
			float4 HL2247 = normalizeResult246;
			float dotResult249 = dot( HL2247 , float4( T200 , 0.0 ) );
			float DotTHL2252 = dotResult249;
			float sinTHL2256 = sqrt( ( 1.0 - ( DotTHL2252 * DotTHL2252 ) ) );
			float4 temp_output_265_0 = ( ( pow( sinTHL2256 , _SecondaryHighlightExponent ) * _SecondaryHighlightStrength * dirAtten102 * lightZone285 ) * _SecondaryHighlightColor * ase_lightColor * ase_lightColor.a );
			float4 OUTPUT_Albedo407 = ( lerpResult332 + temp_output_268_0 + temp_output_265_0 );
			o.Albedo = OUTPUT_Albedo407.rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir343 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult345 = normalize( objToWorldDir343 );
			float dotResult346 = dot( ase_worldlightDir , normalizeResult345 );
			float clampResult353 = clamp( ( ( ( dotResult346 + _Light_Bias ) * _Light_Scale ) * _LightScatter ) , 0.0 , 1.0 );
			float SSS_Effect394 = ( _BaseIllumination * _SSS * clampResult353 );
			float4 lerpResult339 = lerp( ( temp_output_268_0 + temp_output_265_0 ) , OUTPUT_Albedo407 , SSS_Effect394);
			float4 OUTPUT_Emissive398 = lerpResult339;
			o.Emission = OUTPUT_Emissive398.rgb;
			o.Metallic = _Metallic;
			float lerpResult334 = lerp( _VariantColor1_GlossA.a , _Variant_Color2_GlossA.a , tex2DNode335.r);
			float OUTPUT_Smothness412 = lerpResult334;
			o.Smoothness = OUTPUT_Smothness412;
			float Original_HairAlpha392 = ( originalAlphaCutout403 * _Alpha_Level );
			float2 appendResult390 = (float2(_XTiling , 1.0));
			float2 uv_TexCoord376 = i.uv_texcoord * appendResult390;
			float2 appendResult381 = (float2(uv_TexCoord376.x , pow( ( uv_TexCoord376.y * _Stretch ) , 0.5 )));
			float OUTPUT_HairOpacity388 = ( Original_HairAlpha392 * tex2D( _ExtraCuttingR, appendResult381 ).r );
			float temp_output_389_0 = OUTPUT_HairOpacity388;
			o.Alpha = temp_output_389_0;
			#if UNITY_PASS_SHADOWCASTER
			clip( temp_output_389_0 - _Cutoff );
			#endif
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16204
636;221;1009;462;-542.5035;2091.146;1.62573;True;False
Node;AmplifyShaderEditor.CommentaryNode;402;-632.5151,280.1337;Float;False;1958.913;736.6984;Comment;14;311;390;384;364;365;316;315;300;307;299;114;7;404;410;Noise and Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;406;-3766.658,-1337.893;Float;False;3050.46;2470.514;Comment;69;392;331;328;372;329;403;335;267;314;109;264;261;108;260;259;106;286;258;104;107;105;262;326;327;102;257;285;290;256;103;97;396;373;370;289;255;132;371;134;368;254;253;99;98;252;249;94;95;251;248;96;247;200;93;246;245;78;241;77;243;17;305;304;306;268;397;265;292;330;Color and Highlight Mixing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;364;-582.5151,885.101;Float;False;Property;_NoisePower;NoisePower;27;0;Create;True;0;0;False;0;0;0;0;2000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;335;-2762.142,-606.1206;Float;True;Property;_VRTC;VRTC;8;0;Create;True;0;0;False;0;None;fcf2dcfaa2add3347bed3c68ef404e19;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;365;-226.7994,869.5599;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;316;-72.07491,860.832;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;403;-2296.331,-510.8635;Float;False;originalAlphaCutout;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-512.2765,424.4365;Float;False;Property;_BumpPower;BumpPower;16;0;Create;True;0;0;False;0;0.5;1.46;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;315;236.0447,834.2753;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;300;-537.5021,693.4656;Float;False;Property;_Spread;Spread;26;0;Create;True;0;0;False;0;0;0.49;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-73.77025,365.0654;Float;True;Property;_NormalMap;NormalMap;6;0;Create;True;0;0;False;0;cf24829a9bef4734582a302bd6f6d130;e0f59942be39cf14f9e0d0ee1e0b52d9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;404;143.3906,629.5546;Float;False;403;originalAlphaCutout;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;722.4737,330.1337;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;446.4015,661.6004;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;909.0762,452.3024;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0.1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;401;1329.368,272.7834;Float;False;1769.893;663.4403;Comment;11;312;380;376;379;383;391;381;374;393;375;388;Final Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;1409.546,485.2986;Float;False;NoiseFX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-4666.173,-818.6374;Float;False;Property;_MainHighlightPosition;Main Highlight Position;19;0;Create;True;0;0;False;0;0;-0.56;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-4611.419,-1120.539;Float;True;312;NoiseFX;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-3992.72,-1179.694;Float;False;Property;_SecondaryHighlightPosition;Secondary Highlight Position;23;0;Create;True;0;0;False;0;0;-0.36;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;298;-3851.941,-508.676;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;25;-4175.915,-953.6733;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;306;-3607.776,-1151.192;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-3529.548,-530.8989;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-3716.658,-771.6227;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;305;-3364.19,-581.8586;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-3437.132,-1116.554;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-3187.773,-1096.639;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-3236.372,-718.7031;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;405;-4703.304,-412.4611;Float;False;687.4736;934.2229;Comment;6;79;198;280;284;279;197;Math;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexTangentNode;79;-4630.145,-362.4611;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;198;-4653.304,-180.1292;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-2901.15,-1041.931;Float;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;78;-3038.574,-723.9587;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;246;-2708.667,-1048.994;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CrossProductOpNode;197;-4203.83,-313.4554;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2836.758,-693.7408;Float;False;H;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-2392.758,-1058.078;Float;False;HL2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-3489.306,-399.9858;Float;False;T;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-3540.833,-259.7031;Float;False;93;H;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-3588.091,551.6077;Float;False;200;T;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-3604.341,449.2595;Float;False;247;HL2;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-3241.022,-364.4166;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-3064.083,-364.068;Float;False;dotTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;249;-3268.591,476.1266;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-3023.732,481.425;Float;False;DotTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-3555.498,-149.8855;Float;False;94;dotTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;280;-4641.981,156.0276;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3264.076,-148.8628;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-2734.597,484.8329;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;284;-4647.628,342.7618;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;341;-542.1967,1095.895;Float;False;2464.81;682.6744;ScatterLight;15;394;363;357;353;340;352;349;351;348;347;346;345;344;343;342;SSS;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;254;-2533.547,500.5397;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;371;-2728.873,-294.687;Float;False;Property;_VRTC_Scale;VRTC_Scale;11;0;Create;True;0;0;False;0;1;1;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-3060.209,-180.9998;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-2729.725,-381.3201;Float;False;Property;_VRTC_Bias;VRTC_Bias;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;279;-4236.963,244.6978;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;342;-479.9477,1405.031;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SqrtOpNode;132;-2858.072,-225.2531;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;370;-2285.945,-426.237;Float;False;ConstantBiasScale;-1;;7;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-3664.241,196.1259;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;343;-225.4491,1401.88;Float;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SqrtOpNode;255;-2330.928,498.9691;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-2664.505,-204.7087;Float;False;sinTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;373;-1935.277,-600.7404;Float;False;Property;_UseVRTC_BiasAndScale;UseVRTC_BiasAndScale?;9;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;290;-3444.781,238.476;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;345;49.59906,1414.142;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;344;-494.3033,1235.426;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;103;-3234.803,-1.916496;Float;False;3;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-2131.45,498.9688;Float;False;sinTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-247.6851,1548.879;Float;False;Property;_Light_Bias;Light_Bias;1;0;Create;True;0;0;False;0;0;0.0201;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;327;-2427.24,-787.0815;Float;False;Property;_Variant_Color2_GlossA;Variant_Color2_Gloss(A);13;0;Create;True;0;0;False;0;0,0.1356491,0.7867647,0.516;0.1764706,0.1256055,0.04930796,0.503;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;326;-2428.317,-963.6812;Float;False;Property;_VariantColor1_GlossA;VariantColor1_Gloss(A);12;0;Create;True;0;0;False;0;0.8897059,0.1308391,0.1308391,0.516;0.1470588,0.08713162,0.04108997,0.21;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;372;-1643.475,-762.1263;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;346;254.6646,1252.074;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-254.5041,1661.022;Float;False;Property;_Light_Scale;Light_Scale;2;0;Create;True;0;0;False;0;0;2.77;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-2977.938,-10.84821;Float;False;dirAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-2630.373,908.2946;Float;False;256;sinTHL2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-2516.188,51.67668;Float;False;97;sinTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;329;-2045.256,-1287.893;Float;False;Property;_RootColorPowerA;RootColor-Power(A);14;0;Create;True;0;0;False;0;0.1102941,0.1005623,0.1005623,0.453;0,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;107;-2597.844,129.8814;Float;False;Property;_MainHighlightExponent;Main Highlight Exponent;21;0;Create;True;0;0;False;0;0.2;33;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-3266.51,186.3421;Float;False;lightZone;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;-2662.638,673.6901;Float;False;Property;_SecondaryHighlightExponent;Secondary Highlight Exponent;25;0;Create;True;0;0;False;0;0.2;128;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;384;715.2823,694.3094;Float;False;Property;_XTiling;XTiling;30;0;Create;True;0;0;False;0;0;6.26;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;390;1159.397,582.9752;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;259;-2644.141,764.4827;Float;False;Property;_SecondaryHighlightStrength;Secondary Highlight Strength;24;0;Create;True;0;0;False;0;0.25;0.24;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;-1407.002,-1128.471;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;328;-1294.275,-976.7998;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-2448.143,371.9342;Float;False;285;lightZone;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2622.614,840.986;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;-1071.695,-941.9322;Float;False;Property;_TipColorPowerA;TipColor-Power(A);15;0;Create;True;0;0;False;0;0.9448277,1,0,0.484;0.1838235,0.120026,0.02432959,0.791;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;104;-2557.82,297.1773;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;349;487.6428,1298.705;Float;False;ConstantBiasScale;-1;;8;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;351;118.6937,1671.82;Float;False;Property;_LightScatter;LightScatter;3;0;Create;True;0;0;False;0;0;0.355;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;106;-2242,-30.08257;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-2592.595,210.4834;Float;False;Property;_MainHighlightStrength;Main Highlight Strength;20;0;Create;True;0;0;False;0;0.25;0.16;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;258;-2281.745,618.481;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;264;-2017.542,831.6193;Float;False;Property;_SecondaryHighlightColor;Secondary Highlight Color;22;0;Create;True;0;0;False;0;0.8862069,0.8862069,0.8862069,0;1,1,1,0.034;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;267;-2323.583,-261.4672;Float;False;Property;_MainHighlight_Color;MainHighlight_Color;18;0;Create;True;0;0;False;0;0,0,0,0;0.3925173,0.4008352,0.4852941,0.828;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;314;-1991.07,486.8896;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;422;314.8744,-2155.113;Float;False;1833.611;570.7649;Comment;10;433;423;434;420;429;425;421;445;446;447;Movement;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;330;-907.5844,-1195.583;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;782.5613,1351.349;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-2022.083,674.0374;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-598.7312,-830.5269;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;376;1452.762,579.4526;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;380;1379.835,734.2379;Float;False;Property;_Stretch;Stretch;29;0;Create;True;0;0;False;0;0.4961396;1.01;0.01;1.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-2074.68,-48.38425;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-895.7122,10.42883;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;353;994.4028,1338.479;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;421;373.38,-1997.139;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;383;1379.368,821.2239;Float;False;Constant;_Adjust;Adjust;29;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-1691.714,-182.5797;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;340;924.7745,1137.039;Float;False;Property;_BaseIllumination;BaseIllumination;4;0;Create;True;0;0;False;0;0.15;0.154;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;929.132,1229.432;Float;False;Property;_SSS;SSS;5;0;Create;True;0;0;False;0;0;0.889;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;332;-346.5797,-1040.599;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;396;-2091.989,-289.3039;Float;False;Property;_Alpha_Level;Alpha_Level;7;0;Create;True;0;0;False;0;1;1.44;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;379;1711.405,649.4501;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;425;622.9376,-1982.877;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;425.184,-1707.961;Float;False;Property;_PushHairs_Bias;PushHairs_Bias;32;0;Create;True;0;0;False;0;0;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;391;1863.139,734.4855;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;397;-1770.882,-352.9533;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;1352.02,1172.726;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;35.06141,-940.5189;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;394;1591.598,1161.339;Float;False;SSS_Effect;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;445;855.6922,-1930.251;Float;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;447;1101.521,-1881.439;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;400;951.4557,-139.1102;Float;False;860.995;360.5265;Comment;5;291;395;339;398;409;Emissive;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;381;1982.499,560.7893;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;303.9502,-965.624;Float;False;OUTPUT_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;429;411.1858,-2084.723;Float;False;Property;_PushHairs;PushHairs;31;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;392;-1346.511,-410.5788;Float;False;Original_HairAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;420;1356.595,-1952.198;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;977.3808,11.72447;Float;False;407;OUTPUT_Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;989.6982,-100.2515;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;393;2204.727,322.7834;Float;False;392;Original_HairAlpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;433;1109.599,-1708.825;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;374;2182.722,446.7526;Float;True;Property;_ExtraCuttingR;ExtraCutting(R);28;0;Create;True;0;0;False;0;None;6f801cb597fd08f4ca3336f392517f0a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;395;1058.093,106.4162;Float;False;394;SSS_Effect;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;339;1308.01,-85.75253;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;2596.22,391.5271;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;1595.011,-1846.243;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;334;8.17156,-663.4929;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;410;266.5262,365.2551;Float;False;OUTPUT_NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;1825.246,-1766.413;Float;False;OUTPUT_VertexMotion;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;398;1542.451,-89.11021;Float;False;OUTPUT_Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;412;341.6769,-669.2474;Float;False;OUTPUT_Smothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;414;2500.923,-1963.795;Float;False;708.6133;654.589;Comment;8;424;0;29;413;399;408;389;411;FINAL OUTPUTs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;2811.26,394.7545;Float;False;OUTPUT_HairOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;2582.995,-1913.795;Float;False;407;OUTPUT_Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;413;2565.971,-1564.302;Float;False;412;OUTPUT_Smothness;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;399;2550.923,-1746.575;Float;False;398;OUTPUT_Emissive;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;411;2559.048,-1826.162;Float;False;410;OUTPUT_NormalMap;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;29;2552.708,-1653.873;Float;False;Property;_Metallic;Metallic;17;0;Create;True;0;0;False;0;0;0.453;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;2567.712,-1407.594;Float;False;423;OUTPUT_VertexMotion;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;389;2570.967,-1485.191;Float;False;388;OUTPUT_HairOpacity;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2942.537,-1783.504;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;RRF_HumanShaders/HairShader2/HairShader2_AS_RRF_VRTC;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;1;False;-1;1;False;-1;True;1;False;-1;5;False;-1;False;5;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;365;0;364;0
WireConnection;316;0;365;0
WireConnection;403;0;335;4
WireConnection;315;0;316;0
WireConnection;7;5;114;0
WireConnection;311;0;7;2
WireConnection;311;1;300;0
WireConnection;307;0;404;0
WireConnection;307;1;315;0
WireConnection;299;0;311;0
WireConnection;299;1;307;0
WireConnection;299;2;300;0
WireConnection;312;0;299;0
WireConnection;298;0;303;0
WireConnection;298;1;313;0
WireConnection;306;0;244;0
WireConnection;306;1;313;0
WireConnection;304;0;298;0
WireConnection;304;1;25;2
WireConnection;305;0;25;1
WireConnection;305;1;304;0
WireConnection;305;2;25;3
WireConnection;243;0;306;0
WireConnection;243;1;25;2
WireConnection;241;0;25;1
WireConnection;241;1;243;0
WireConnection;241;2;25;3
WireConnection;77;0;305;0
WireConnection;77;1;17;0
WireConnection;245;0;241;0
WireConnection;245;1;17;0
WireConnection;78;0;77;0
WireConnection;246;0;245;0
WireConnection;197;0;79;0
WireConnection;197;1;198;0
WireConnection;93;0;78;0
WireConnection;247;0;246;0
WireConnection;200;0;197;0
WireConnection;95;0;200;0
WireConnection;95;1;96;0
WireConnection;94;0;95;0
WireConnection;249;0;248;0
WireConnection;249;1;251;0
WireConnection;252;0;249;0
WireConnection;99;0;98;0
WireConnection;99;1;98;0
WireConnection;253;0;252;0
WireConnection;253;1;252;0
WireConnection;254;0;253;0
WireConnection;134;0;99;0
WireConnection;279;0;280;0
WireConnection;279;1;284;0
WireConnection;132;0;134;0
WireConnection;370;3;335;0
WireConnection;370;1;368;0
WireConnection;370;2;371;0
WireConnection;289;0;279;0
WireConnection;289;1;279;0
WireConnection;289;2;279;0
WireConnection;343;0;342;0
WireConnection;255;0;254;0
WireConnection;97;0;132;0
WireConnection;373;1;335;0
WireConnection;373;0;370;0
WireConnection;290;0;289;0
WireConnection;345;0;343;0
WireConnection;103;0;98;0
WireConnection;256;0;255;0
WireConnection;372;0;373;0
WireConnection;346;0;344;0
WireConnection;346;1;345;0
WireConnection;102;0;103;0
WireConnection;285;0;290;0
WireConnection;390;0;384;0
WireConnection;331;0;329;4
WireConnection;331;1;372;1
WireConnection;328;0;326;0
WireConnection;328;1;327;0
WireConnection;328;2;372;0
WireConnection;349;3;346;0
WireConnection;349;1;347;0
WireConnection;349;2;348;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;258;0;257;0
WireConnection;258;1;262;0
WireConnection;330;0;328;0
WireConnection;330;1;329;0
WireConnection;330;2;331;0
WireConnection;352;0;349;0
WireConnection;352;1;351;0
WireConnection;261;0;258;0
WireConnection;261;1;259;0
WireConnection;261;2;260;0
WireConnection;261;3;286;0
WireConnection;333;0;292;4
WireConnection;333;1;372;2
WireConnection;376;0;390;0
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;109;2;104;0
WireConnection;109;3;286;0
WireConnection;265;0;261;0
WireConnection;265;1;264;0
WireConnection;265;2;314;0
WireConnection;265;3;314;2
WireConnection;353;0;352;0
WireConnection;268;0;267;0
WireConnection;268;1;109;0
WireConnection;268;2;314;0
WireConnection;268;3;314;2
WireConnection;332;0;330;0
WireConnection;332;1;292;0
WireConnection;332;2;333;0
WireConnection;379;0;376;2
WireConnection;379;1;380;0
WireConnection;425;0;421;2
WireConnection;391;0;379;0
WireConnection;391;1;383;0
WireConnection;397;0;403;0
WireConnection;397;1;396;0
WireConnection;363;0;340;0
WireConnection;363;1;357;0
WireConnection;363;2;353;0
WireConnection;273;0;332;0
WireConnection;273;1;268;0
WireConnection;273;2;265;0
WireConnection;394;0;363;0
WireConnection;445;0;425;0
WireConnection;445;1;446;0
WireConnection;381;0;376;1
WireConnection;381;1;391;0
WireConnection;407;0;273;0
WireConnection;392;0;397;0
WireConnection;420;0;429;0
WireConnection;420;1;445;0
WireConnection;420;2;447;0
WireConnection;291;0;268;0
WireConnection;291;1;265;0
WireConnection;374;1;381;0
WireConnection;339;0;291;0
WireConnection;339;1;409;0
WireConnection;339;2;395;0
WireConnection;375;0;393;0
WireConnection;375;1;374;1
WireConnection;434;0;420;0
WireConnection;434;1;433;0
WireConnection;334;0;326;4
WireConnection;334;1;327;4
WireConnection;334;2;335;1
WireConnection;410;0;7;0
WireConnection;423;0;434;0
WireConnection;398;0;339;0
WireConnection;412;0;334;0
WireConnection;388;0;375;0
WireConnection;0;0;408;0
WireConnection;0;1;411;0
WireConnection;0;2;399;0
WireConnection;0;3;29;0
WireConnection;0;4;413;0
WireConnection;0;9;389;0
WireConnection;0;10;389;0
WireConnection;0;11;424;0
ASEEND*/
//CHKSM=BD2B8BDBBA614C1B7A5AC8BD521C196CD1405B80