return {
	{
		name = "Plantoid_Petit",
		remotes =  {
			Tige_et_support =  {
				ip    =  "192.168.10.52",
				port  =  12345,
				size  =  400
			},
			Spots =  {
				ip    =  "192.168.10.70",
				port  =  12345,
				RGBW  =  true,
				size  =  241
			},
		},
		sensors = {
			{
				ip    =  "192.168.10.209",
				port  =  12345,
			},
		},
		parts =  {
			Supports =  {
				{
					remote =  "Tige_et_support",
					off =  0,
					size =  37
				},
				{
					remote =  "Tige_et_support",
					off =  37,
					size =  37
				},
				{
					remote =  "Tige_et_support",
					off =  37+37,
					size =  35
				},
				{
					remote =  "Tige_et_support",
					off =  37+37+35,
					size =  35
				},
			},
			Spots =  {
				{
					remote =  "Spots",
					off =  0,
					size =  241
				},
			},
		}
	},
	{
		name =  "Plantoid_Moyen",
		remotes =  {
			Petales =  {
				ip    =  "192.168.10.60",
				port  =  12345,
				size  =  111+111+114+112+111+108
			},
			Feuilles_L =  {
				ip    =  "192.168.10.145",
				port  =  12345,
				size  =  352
			},
			Feuilles_R =  {
				ip    =  "192.168.10.61",
				port  =  12345,
				size  =  352
			},
			Tige_et_support =  {
				ip    =  "192.168.10.62", -- 62
				port  =  12345,
				size  =  1000
			},
			Spots =  {
				ip    =  "192.168.10.228",
				port  =  12345,
				RGBW  =  true,
				size  =  241
			},
		},
		sensors = {
			{
				ip    =  "192.168.10.127",
				port  =  12345,
			},
		},
		parts =  {
			Petales =  {
				{
					remote =  "Petales",
					off =  0,
					size =  111
				},
				{
					remote =  "Petales",
					off =  111,
					size =  111
				},
				{
					remote =  "Petales",
					off =  111+111,
					size =  114
				},
				{
					remote =  "Petales",
					off =  111+111+114,
					size =  112
				},
				{
					remote =  "Petales",
					off =  111+111+114+112,
					size =  111
				},
				{
					remote =  "Petales",
					off =  111+111+114+112+111,
					size =  108
				},
			},
			Spots =  {
				{
					remote =  "Spots",
					off =  0,
					size =  241
				}
			},
			Feuilles_L =  {
				{
					remote =  "Feuilles_L",
					off =  0,
					size =  210
				},
				{
					remote =  "Feuilles_L",
					off =  210,
					size =  142
				},
			},
			Feuilles_R =  {
				{
					remote =  "Feuilles_R",
					off =  0,
					size =  210
				},
				{
					remote =  "Feuilles_R",
					off =  210,
					size =  162
				},
			},
			Tiges =  {
				{
					remote =  "Tige_et_support",
					off =  51+51+58+57,
					size =  53,
				},
				{
					remote =  "Tige_et_support",
					off =  51+51+58+57+53,
					size =  53,
					invert =  true
				},
				{
					remote =  "Tige_et_support",
					off =  51+51+58+57+53+53,
					size =  33,
				},
				{
					remote =  "Tige_et_support",
					off =  51+51+58+57+53+53+33,
					size =  33,
					invert =  true
				}
			},
			Supports =  {
				{
					remote =  "Tige_et_support",
					off =  0,
					size =  51
				},
				{
					remote =  "Tige_et_support",
					off =  51,
					size =  51,
					invert =  true
				},
				{
					remote =  "Tige_et_support",
					off =  51+51,
					size =  58
				},
				{
					remote =  "Tige_et_support",
					off =  51+51+58,
					size =  57,
					invert =  true
				}
			}
		}
	},
	{
		name = "Plantoid_Grand",
		remotes =  {
			Petales =  {
				ip    =  "192.168.10.147",
				port  =  12345,
				size  =  240*5
			},
			Feuilles_L =  {
				ip    =  "192.168.10.71",
				port  =  12345,
				size  =  756
			},

			Feuilles_R =  {
				ip    =  "192.168.10.73",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.10.145",
				port  =  12345,
				size  =  1000
			},
			Spots =  {
				ip    =  "192.168.10.121",
				port  =  12345,
				RGBW  =  true,
				size  =  241
			},
		},
		sensors = {
			{
				ip    =  "192.168.10.108",
				port  =  12345,
			},
			{
				ip    =  "192.168.10.197",
				port  =  12345,
			},
		},
		parts =  {
			Petales =  {
				{
					remote =  "Petales",
					off =  0,
					size =  240
				},
				{
					remote =  "Petales",
					off =  240,
					size =  240
				},
				{
					remote =  "Petales",
					off =  240*2,
					size =  240
				},
				{
					remote =  "Petales",
					off =  240*3,
					size =  240
				},
				{
					remote =  "Petales",
					off =  240*4,
					size =  240
				},
			},
			Spots =  {
				{
					remote =  "Spots",
					off =  0,
					size =  241
				}
			},
			Feuilles_L =  {
				{
					remote =  "Feuilles_L",
					off =  0,
					size =  1000
				},
			},
			Feuilles_R =  {
				{
					remote =  "Feuilles_R",
					off =  0,
					size =  1000
				},
			},
			Tiges =  {
				{
					remote =  "Tige_et_support",
					off =  0,
					size =  1000
				},
			},
			Supports =  {
				{
					remote =  "Tige_et_support",
					off =  0,
					size =  58
				},
				{
					remote =  "Tige_et_support",
					off =  58,
					size =  56,
					invert =  true
				},
				{
					remote =  "Tige_et_support",
					off =  218,
					size =  53
				},
				{
					remote =  "Tige_et_support",
					off =  271,
					size =  53,
					invert =  true
				}
			}
		}
	},
	{
		name = "Plantoid_test",
		remotes =  {
			Spots =  {
				ip    =  "192.168.10.109",
				port  =  12345,
				size =  93,
				RGBW  =  true
			}
		},
		sensors = {
			{
				ip    =  "192.168.31.109",
				port  =  12345,
			},
		},
		parts =  {
			Anneaux =  {
				{
					remote =  "Spots",
					off =  0,
					size =  32
				},
				{
					remote =  "Spots",
					off =  32,
					size =  24
				},
				{
					remote =  "Spots",
					off =  56,
					size =  16
				},
				{
					remote =  "Spots",
					off =  72,
					size =  12
				},
				{
					remote =  "Spots",
					off =  84,
					size =  8
				},
				{
					remote =  "Spots",
					off =  92,
					size =  1
				}
			}
		}
	},
	-- {
	-- 	name = "Plantoid_test2",
	-- 	remotes =  {
	-- 		All =  {
	-- 			ip    =  "192.168.12.60",
	-- 			port  =  12345,
	-- 			size =  320,
	-- 			RGBW  =  false
	-- 		}
	-- 	},
	-- 	sensors = {},
	-- 	parts =  {
	-- 		Tiges =  {
	-- 			{
	-- 				remote =  "All",
	-- 				off =  0,
	-- 				size =  38
	-- 			},
	-- 			{
	-- 				remote =  "All",
	-- 				off =  204,
	-- 				size =  38,
	-- 				invert = true
	-- 			}
	-- 		},
	-- 		Petales =  {
	-- 			{
	-- 				remote =  "All",
	-- 				off =  48,
	-- 				size =  27
	-- 			},
	-- 			{
	-- 				remote =  "All",
	-- 				off =  75,
	-- 				size =  38
	-- 			},
	-- 			{
	-- 				remote =  "All",
	-- 				off =  113,
	-- 				size =  35
	-- 			},
	-- 			{
	-- 				remote =  "All",
	-- 				off =  148,
	-- 				size =  35
	-- 			}
	-- 		}
	-- 	}
	-- },
}
