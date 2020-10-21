// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RRF_HumanShaders/HairShader2/HairShader2_AS_RRF_Mod1"
{
	Properties
	{
		_EdgeRimLight("EdgeRimLight", Range( 0 , 4)) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_TranslucentEffect("TranslucentEffect", Range( 0 , 100)) = 0.25
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_BaseColorGloss("BaseColor-Gloss", Color) = (0.8455882,0.8076825,0.6839316,0.522)
		_BaseTone_Alpha("BaseTone_Alpha", 2D) = "white" {}
		_BaseTipColorPower("BaseTipColor-Power", Color) = (1,0,0,0)
		_AlphaLevel("AlphaLevel", Range( 0 , 2)) = 2
		_VariaitonFromBase("VariaitonFromBase", Range( 0 , 1)) = 0.8
		_NormalMap("NormalMap", 2D) = "bump" {}
		_BumpPower("BumpPower", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_MainHighlight_Color("MainHighlight_Color", Color) = (0,0,0,0)
		_MainHighlightPosition("Main Highlight Position", Range( -1 , 3)) = 0
		_MainHighlightStrength("Main Highlight Strength", Range( 0 , 2)) = 0.25
		_MainHighlightExponent("Main Highlight Exponent", Range( 0 , 1000)) = 0.2
		_SecondaryHighlightColor("Secondary Highlight Color", Color) = (0.8862069,0.8862069,0.8862069,0)
		_SecondaryHighlightPosition("Secondary Highlight Position", Range( -1 , 3)) = 0
		_SecondaryHighlightStrength("Secondary Highlight Strength", Range( 0 , 2)) = 0.25
		_SecondaryHighlightExponent("Secondary Highlight Exponent", Range( 0 , 1000)) = 0.2
		_Spread("Spread", Range( -1 , 1)) = 0
		_Noise("Noise", Range( 0 , 1)) = 0
		_NoiseTiling("NoiseTiling", Vector) = (1200,1000,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha DstColor
		
		AlphaToMask On
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Translucency;
		};

		uniform float _BumpPower;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _BaseTipColorPower;
		uniform float4 _BaseColorGloss;
		uniform sampler2D _BaseTone_Alpha;
		uniform float4 _BaseTone_Alpha_ST;
		uniform float4 _MainHighlight_Color;
		uniform float2 _NoiseTiling;
		uniform float _Noise;
		uniform float _Spread;
		uniform float _MainHighlightPosition;
		uniform float _MainHighlightExponent;
		uniform float _MainHighlightStrength;
		uniform float _SecondaryHighlightPosition;
		uniform float _SecondaryHighlightExponent;
		uniform float _SecondaryHighlightStrength;
		uniform float4 _SecondaryHighlightColor;
		uniform float _VariaitonFromBase;
		uniform float _Metallic;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _EdgeRimLight;
		uniform float _TranslucentEffect;
		uniform float _AlphaLevel;
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


		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + c;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _BumpPower );
			float3 lerpResult113 = lerp( float3(0.5,0.5,1) , tex2DNode7 , _BumpPower);
			float3 normalizeResult15 = normalize( lerpResult113 );
			float3 OUTPUT_NORMAL333 = normalizeResult15;
			o.Normal = OUTPUT_NORMAL333;
			float2 uv_BaseTone_Alpha = i.uv_texcoord * _BaseTone_Alpha_ST.xy + _BaseTone_Alpha_ST.zw;
			float4 tex2DNode1 = tex2D( _BaseTone_Alpha, uv_BaseTone_Alpha );
			float4 lerpResult293 = lerp( _BaseTipColorPower , _BaseColorGloss , pow( tex2DNode1.g , ( _BaseTipColorPower.a * 10.0 ) ));
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 T200 = cross( ase_worldTangent , ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float2 uv_TexCoord315 = i.uv_texcoord * _NoiseTiling;
			float simplePerlin2D316 = snoise( uv_TexCoord315 );
			float lerpResult318 = lerp( tex2DNode7.g , simplePerlin2D316 , _Noise);
			float NoiseFX312 = ( ( tex2DNode7.g + lerpResult318 ) * _Spread );
			float4 appendResult305 = (float4(ase_worldlightDir.x , ( ase_worldlightDir.y + ( NoiseFX312 + _MainHighlightPosition ) ) , ase_worldlightDir.z , 0.0));
			float4 normalizeResult78 = normalize( ( float4( ase_worldViewDir , 0.0 ) + appendResult305 ) );
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
			float4 mainHL339 = ( _MainHighlight_Color * ( pow( sinTH97 , _MainHighlightExponent ) * _MainHighlightStrength * dirAtten102 * lightZone285 ) * ase_lightColor * ase_lightColor.a );
			float4 appendResult241 = (float4(ase_worldlightDir.x , ( ( _SecondaryHighlightPosition + NoiseFX312 ) + ase_worldlightDir.y ) , ase_worldlightDir.z , 0.0));
			float4 normalizeResult246 = normalize( ( appendResult241 + float4( ase_worldViewDir , 0.0 ) ) );
			float4 HL2247 = normalizeResult246;
			float dotResult249 = dot( HL2247 , float4( T200 , 0.0 ) );
			float DotTHL2252 = dotResult249;
			float sinTHL2256 = sqrt( ( 1.0 - ( DotTHL2252 * DotTHL2252 ) ) );
			float4 secondaryHL337 = ( ( pow( sinTHL2256 , _SecondaryHighlightExponent ) * _SecondaryHighlightStrength * dirAtten102 * lightZone285 ) * _SecondaryHighlightColor * ase_lightColor * ase_lightColor.a );
			float4 temp_cast_4 = (1.0).xxxx;
			float4 lerpResult144 = lerp( temp_cast_4 , tex2DNode1 , _VariaitonFromBase);
			float4 clampResult275 = clamp( ( ( lerpResult293 + mainHL339 + secondaryHL337 ) * lerpResult144 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Albedo = clampResult275.rgb;
			o.Emission = ( mainHL339 + secondaryHL337 ).rgb;
			float OUTPUT_METALNESS345 = ( tex2DNode1.r * _Metallic );
			o.Metallic = OUTPUT_METALNESS345;
			float OUTPUT_GLOSS347 = _BaseColorGloss.a;
			o.Smoothness = OUTPUT_GLOSS347;
			float fresnelNdotV31 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode31 = ( -0.9 + 0.45 * pow( 1.0 - fresnelNdotV31, _EdgeRimLight ) );
			float fresnelNdotV205 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode205 = ( -0.1 + 0.9 * pow( 1.0 - fresnelNdotV205, 1.51 ) );
			float HighlightResults326 = ( ( 1.0 - fresnelNode31 ) * fresnelNode205 );
			float4 clampResult223 = clamp( ( clampResult275 * HighlightResults326 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Translucency = ( clampResult223 * _TranslucentEffect ).rgb;
			float OUTPUT_OPACITY343 = pow( ( tex2DNode1.a * tex2DNode1.a ) , _AlphaLevel );
			float temp_output_344_0 = OUTPUT_OPACITY343;
			o.Alpha = temp_output_344_0;
			#if UNITY_PASS_SHADOWCASTER
			clip( temp_output_344_0 - _Cutoff );
			#endif
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom keepalpha fullforwardshadows exclude_path:deferred 

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
			#pragma target 3.0
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
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
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
658;260;1293;807;9137.982;3186.118;10.1097;True;False
Node;AmplifyShaderEditor.CommentaryNode;332;-2215.045,1199.803;Float;False;1985.325;747.9399;Noise from the normal map;15;319;315;316;311;299;312;112;113;317;300;318;7;114;15;333;Extra noise and Frizz - OUTPUT NORMAL MAP;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;319;-2165.045,1677.666;Float;False;Property;_NoiseTiling;NoiseTiling;28;0;Create;True;0;0;False;0;1200,1000;1200,1000;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;114;-1859.558,1377.065;Float;False;Property;_BumpPower;BumpPower;16;0;Create;True;0;0;False;0;0.5;0.475;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;315;-1860.638,1660.23;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1200,10;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;317;-2064.321,1818.234;Float;False;Property;_Noise;Noise;27;0;Create;True;0;0;False;0;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-1419.027,1465.146;Float;True;Property;_NormalMap;NormalMap;15;0;Create;True;0;0;False;0;None;8126a85a9900e314395584d32d505790;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;316;-1550.111,1670.3;Float;False;Simplex2D;1;0;FLOAT2;0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;318;-1058.813,1635.254;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;311;-846.8767,1526.681;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;300;-1475.983,1832.743;Float;False;Property;_Spread;Spread;26;0;Create;True;0;0;False;0;0;-0.29;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-670.4291,1666.987;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;322;-6507.499,-1211.908;Float;False;2067.657;867.3465;This all does stuff (based on pure trial and error);17;247;244;246;93;245;78;241;77;17;305;243;304;306;298;25;303;313;Highlight calculations;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;-472.72,1662.32;Float;False;NoiseFX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;303;-6457.499,-440.8927;Float;False;Property;_MainHighlightPosition;Main Highlight Position;19;0;Create;True;0;0;False;0;0;-0.19;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;-6428.182,-663.4873;Float;True;312;NoiseFX;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-6446.095,-1137.111;Float;False;Property;_SecondaryHighlightPosition;Secondary Highlight Position;23;0;Create;True;0;0;False;0;0;-1;-1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;298;-6059.602,-490.8877;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;25;-6459.39,-970.3469;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;306;-5815.437,-1133.406;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;-5781.247,-538.2753;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-5924.319,-753.8352;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-5644.793,-1098.768;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;305;-5571.852,-564.0703;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;320;-5687.292,-115.4326;Float;False;1270.542;394.0196;Kind of a weird back scatter effect ;7;79;198;197;200;95;94;96;Frizzy Back Scatter DotTH;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-5352.319,-590.8566;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;241;-5395.435,-1078.853;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexTangentNode;79;-5637.292,-65.43258;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;245;-5108.811,-1024.145;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldNormalVector;198;-5634.239,99.58698;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;78;-5154.521,-596.1122;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalizeNode;246;-4916.327,-1031.208;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-4935.322,-598.9181;Float;False;H;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CrossProductOpNode;197;-5349.734,24.3991;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;324;-2834.687,-1334.503;Float;False;1713.508;267.3485;Another light scatter effect;8;248;251;249;252;253;254;255;256;Sin TL2;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-5260.446,136.6158;Float;False;93;H;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;-5136.797,17.50114;Float;False;T;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-4693.429,-1035.705;Float;False;HL2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;251;-2768.437,-1182.154;Float;False;200;T;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;248;-2784.687,-1284.503;Float;False;247;HL2;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;95;-4866.089,24.52576;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;323;-4099.244,-1491.221;Float;False;1232.397;435.3572;A tangent based Sactter effect;7;99;134;132;97;103;102;98;More Scatter sinTH and direction Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-4659.75,17.39066;Float;False;dotTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;249;-2448.936,-1257.636;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-4049.244,-1345.494;Float;False;94;dotTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-2204.079,-1252.337;Float;False;DotTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;321;-5699.563,433.9011;Float;False;1314.185;418.2802;Get where the light is coming from;6;280;284;279;290;285;331;Lightzone;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;253;-1914.944,-1248.929;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;280;-5649.563,483.9011;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3719.379,-1358.811;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;284;-5637.385,673.1812;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;279;-5280.993,575.6573;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-3515.512,-1390.948;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;254;-1713.895,-1233.223;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;331;-5099.017,512.9522;Float;False;219;206;Boosting;1;289;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SqrtOpNode;255;-1511.275,-1234.793;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SqrtOpNode;132;-3313.375,-1435.201;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-5048.017,563.9522;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1364.18,-1242.277;Float;False;sinTHL2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-3109.847,-1441.221;Float;False;sinTH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;103;-3690.106,-1211.864;Float;False;3;0;FLOAT;-1;False;1;FLOAT;-1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;290;-4834.143,559.3709;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;336;-3086.733,-669.298;Float;False;1499.461;947.2432;Main Highlight;11;268;109;329;267;106;108;286;104;105;107;339;Main Highlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;335;-3097.332,324.0962;Float;False;1688.762;681.2662;Secondary Highlight;11;257;262;260;259;258;328;261;264;314;265;337;Secondary Highlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-3036.733,-254.6544;Float;False;Property;_MainHighlightExponent;Main Highlight Exponent;21;0;Create;True;0;0;False;0;0.2;181;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-2955.077,-332.8592;Float;False;97;sinTH;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;262;-3047.332,490.9128;Float;False;Property;_SecondaryHighlightExponent;Secondary Highlight Exponent;25;0;Create;True;0;0;False;0;0.2;1000;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;257;-3005.067,374.0962;Float;False;256;sinTHL2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;102;-3433.241,-1220.796;Float;False;dirAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;285;-4613.41,548.0764;Float;False;lightZone;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-2996.709,-87.35839;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-3031.484,-174.0523;Float;False;Property;_MainHighlightStrength;Main Highlight Strength;20;0;Create;True;0;0;False;0;0.25;1.31;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-2986.723,0.08675718;Float;False;285;lightZone;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;328;-2645.881,771.1169;Float;False;285;lightZone;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2712.914,683.9949;Float;False;102;dirAtten;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;349;-925.4305,-966.0439;Float;False;1287.973;1179.764;Main Color;21;292;297;295;2;143;145;1;294;293;340;338;273;144;28;5;4;343;29;30;345;347;Main Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;258;-2627.758,487.2766;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;-2835.436,598.896;Float;False;Property;_SecondaryHighlightStrength;Secondary Highlight Strength;24;0;Create;True;0;0;False;0;0.25;1.06;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;106;-2680.89,-414.6184;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;264;-2331.542,666.1967;Float;False;Property;_SecondaryHighlightColor;Secondary Highlight Color;22;0;Create;True;0;0;False;0;0.8862069,0.8862069,0.8862069,0;0.6176471,0.4584119,0.3360727,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;314;-2305.86,844.7748;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-2312.224,517.0463;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-795.7565,-722.398;Float;False;Constant;_Float2;Float 2;19;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;-860.2825,-916.0439;Float;False;Property;_BaseTipColorPower;BaseTipColor-Power;12;0;Create;True;0;0;False;0;1,0,0,0;0.2058824,0.08828302,0.01211073,0.628;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;267;-2639.488,-619.298;Float;False;Property;_MainHighlight_Color;MainHighlight_Color;18;0;Create;True;0;0;False;0;0,0,0,0;0.375,0.2193712,0.1185662,0.641;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;329;-2529.439,-273.857;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-2513.57,-432.92;Float;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;325;-5739.762,1052.933;Float;False;1800.461;638.1198;Dual Band Highlights;11;326;219;205;204;214;212;213;31;211;210;209;Dual band Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-576.6129,-761.9971;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-852.7686,-225.8419;Float;True;Property;_BaseTone_Alpha;BaseTone_Alpha;11;0;Create;True;0;0;False;0;None;d278b4721754dd64ebf3ae49a82076b9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-2148.508,-515.983;Float;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-1861.998,613.7383;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-5681.866,1256.17;Float;False;Property;_EdgeRimLight;EdgeRimLight;0;0;Create;True;0;0;False;0;0;1.5;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-5683.861,1102.933;Float;False;Constant;_Bias1;Bias1;19;0;Create;True;0;0;False;0;-0.9;-0.939;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;-5683.861,1182.933;Float;False;Constant;_Scale1;Scale1;21;0;Create;True;0;0;False;0;0.45;0.459;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-5682.943,1395.634;Float;False;Constant;_Bias2;Bias2;23;0;Create;True;0;0;False;0;-0.1;0.148;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-5683.943,1482.634;Float;False;Constant;_Scale2;Scale2;24;0;Create;True;0;0;False;0;0.9;0.905;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;31;-5216.238,1220.245;Float;False;Standard;WorldNormal;LightDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;339;-1896.087,-534.0441;Float;False;mainHL;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;337;-1629.4,690.456;Float;False;secondaryHL;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-5689.762,1578.77;Float;False;Constant;_Power2;Power2;25;0;Create;True;0;0;False;0;1.51;1.51;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;294;-325.4302,-530.7054;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-875.4305,-619.2245;Float;False;Property;_BaseColorGloss;BaseColor-Gloss;10;0;Create;True;0;0;False;0;0.8455882,0.8076825,0.6839316,0.522;0.08823532,0.04674858,0.009083046,0.522;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;338;-345.9396,-304.2888;Float;False;337;secondaryHL;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;340;-336.0298,-427.9238;Float;False;339;mainHL;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;293;-66.92357,-696.7515;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-783.678,-429.0974;Float;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-870.0311,-316.0338;Float;False;Property;_VariaitonFromBase;VariaitonFromBase;14;0;Create;True;0;0;False;0;0.8;0.359;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;204;-4788.768,1245.076;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;205;-5220.739,1419.893;Float;False;Standard;WorldNormal;LightDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;350;654.9891,-502.6239;Float;False;2489.434;922.014;Comment;15;275;327;3;39;0;346;348;223;217;224;291;341;342;334;344;Final gather and output;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;177.4522,-503.9032;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-4534.795,1316.089;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;144;-315.7527,-218.5517;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;704.9891,-449.0225;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;112;-1415.427,1249.803;Float;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;0.5,0.5,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;-4221.229,1304.201;Float;False;HighlightResults;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-820.9368,-4.01712;Float;False;Property;_AlphaLevel;AlphaLevel;13;0;Create;True;0;0;False;0;2;0.22;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;327;727.4037,-263.2242;Float;False;326;HighlightResults;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;275;1080.506,-452.6239;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;113;-901.1859,1304.44;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-826.0938,98.72032;Float;False;Property;_Metallic;Metallic;17;0;Create;True;0;0;False;0;0;0.704;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-325.2064,-84.69691;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1265.889,-277.9408;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-329.5142,76.96235;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;4;-134.9874,-38.20607;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;15;-694.447,1306.524;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;217;1445.905,155.8593;Float;False;Property;_TranslucentEffect;TranslucentEffect;2;0;Create;True;0;0;False;0;0.25;1.8;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;1962.01,-97.25114;Float;False;339;mainHL;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;223;1485.027,-278.3479;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;342;1959.401,7.971542;Float;False;337;secondaryHL;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;347;-580.3302,-518.4738;Float;False;OUTPUT_GLOSS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;343;93.45434,-9.266474;Float;False;OUTPUT_OPACITY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;345;79.54276,92.59763;Float;False;OUTPUT_METALNESS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;333;-457.8116,1303.468;Float;False;OUTPUT_NORMAL;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;2255.847,238.8677;Float;False;343;OUTPUT_OPACITY;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;2173.325,-143.0899;Float;False;333;OUTPUT_NORMAL;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;2235.703,-51.43538;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;2232.646,42.72972;Float;False;345;OUTPUT_METALNESS;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;348;2249.01,110.6365;Float;False;347;OUTPUT_GLOSS;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;1870.604,156.7812;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2877.423,-35.60988;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;RRF_HumanShaders/HairShader2/HairShader2_AS_RRF_Mod1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;5;False;-1;2;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;1;3;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;315;0;319;0
WireConnection;7;5;114;0
WireConnection;316;0;315;0
WireConnection;318;0;7;2
WireConnection;318;1;316;0
WireConnection;318;2;317;0
WireConnection;311;0;7;2
WireConnection;311;1;318;0
WireConnection;299;0;311;0
WireConnection;299;1;300;0
WireConnection;312;0;299;0
WireConnection;298;0;313;0
WireConnection;298;1;303;0
WireConnection;306;0;244;0
WireConnection;306;1;313;0
WireConnection;304;0;25;2
WireConnection;304;1;298;0
WireConnection;243;0;306;0
WireConnection;243;1;25;2
WireConnection;305;0;25;1
WireConnection;305;1;304;0
WireConnection;305;2;25;3
WireConnection;77;0;17;0
WireConnection;77;1;305;0
WireConnection;241;0;25;1
WireConnection;241;1;243;0
WireConnection;241;2;25;3
WireConnection;245;0;241;0
WireConnection;245;1;17;0
WireConnection;78;0;77;0
WireConnection;246;0;245;0
WireConnection;93;0;78;0
WireConnection;197;0;79;0
WireConnection;197;1;198;0
WireConnection;200;0;197;0
WireConnection;247;0;246;0
WireConnection;95;0;200;0
WireConnection;95;1;96;0
WireConnection;94;0;95;0
WireConnection;249;0;248;0
WireConnection;249;1;251;0
WireConnection;252;0;249;0
WireConnection;253;0;252;0
WireConnection;253;1;252;0
WireConnection;99;0;98;0
WireConnection;99;1;98;0
WireConnection;279;0;280;0
WireConnection;279;1;284;0
WireConnection;134;0;99;0
WireConnection;254;0;253;0
WireConnection;255;0;254;0
WireConnection;132;0;134;0
WireConnection;289;0;279;0
WireConnection;289;1;279;0
WireConnection;289;2;279;0
WireConnection;256;0;255;0
WireConnection;97;0;132;0
WireConnection;103;0;98;0
WireConnection;290;0;289;0
WireConnection;102;0;103;0
WireConnection;285;0;290;0
WireConnection;258;0;257;0
WireConnection;258;1;262;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;261;0;258;0
WireConnection;261;1;259;0
WireConnection;261;2;260;0
WireConnection;261;3;328;0
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;109;2;104;0
WireConnection;109;3;286;0
WireConnection;295;0;292;4
WireConnection;295;1;297;0
WireConnection;268;0;267;0
WireConnection;268;1;109;0
WireConnection;268;2;329;0
WireConnection;268;3;329;2
WireConnection;265;0;261;0
WireConnection;265;1;264;0
WireConnection;265;2;314;0
WireConnection;265;3;314;2
WireConnection;31;1;209;0
WireConnection;31;2;210;0
WireConnection;31;3;211;0
WireConnection;339;0;268;0
WireConnection;337;0;265;0
WireConnection;294;0;1;2
WireConnection;294;1;295;0
WireConnection;293;0;292;0
WireConnection;293;1;2;0
WireConnection;293;2;294;0
WireConnection;204;0;31;0
WireConnection;205;1;213;0
WireConnection;205;2;212;0
WireConnection;205;3;214;0
WireConnection;273;0;293;0
WireConnection;273;1;340;0
WireConnection;273;2;338;0
WireConnection;219;0;204;0
WireConnection;219;1;205;0
WireConnection;144;0;143;0
WireConnection;144;1;1;0
WireConnection;144;2;145;0
WireConnection;3;0;273;0
WireConnection;3;1;144;0
WireConnection;326;0;219;0
WireConnection;275;0;3;0
WireConnection;113;0;112;0
WireConnection;113;1;7;0
WireConnection;113;2;114;0
WireConnection;28;0;1;4
WireConnection;28;1;1;4
WireConnection;39;0;275;0
WireConnection;39;1;327;0
WireConnection;30;0;1;1
WireConnection;30;1;29;0
WireConnection;4;0;28;0
WireConnection;4;1;5;0
WireConnection;15;0;113;0
WireConnection;223;0;39;0
WireConnection;347;0;2;4
WireConnection;343;0;4;0
WireConnection;345;0;30;0
WireConnection;333;0;15;0
WireConnection;291;0;341;0
WireConnection;291;1;342;0
WireConnection;224;0;223;0
WireConnection;224;1;217;0
WireConnection;0;0;275;0
WireConnection;0;1;334;0
WireConnection;0;2;291;0
WireConnection;0;3;346;0
WireConnection;0;4;348;0
WireConnection;0;7;224;0
WireConnection;0;9;344;0
WireConnection;0;10;344;0
ASEEND*/
//CHKSM=3C3187C581D8BE82964DA591C7A7EA15CD656DA6