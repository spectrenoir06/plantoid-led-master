return {
	{
		name = "Plantoid_Petit",
		remotes =  {
			Petales =  {
				ip    =  "192.168.12.50",
				port  =  12345,
				size  =  288
			},
			Spots =  {
				ip    =  "192.168.12.51",
				port  =  12345,
				RGBW  =  true,
				size  =  93
			},
			Feuilles =  {
				ip    =  "192.168.12.52",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.12.53",
				port  =  12345,
				size  =  500
			},
		},
		parts =  {
		}
	},
	{
		name =  "Plantoid_Moyen",
		remotes =  {
			Petales =  {
				ip    =  "192.168.12.68",
				port  =  12345,
				size  =  432
			},
			Spots =  {
				ip    =  "192.168.12.61",
				port  =  12345,
				RGBW  =  true,
				size  =  93
			},
			Feuilles =  {
				ip    =  "192.168.12.62",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.12.63",
				port  =  12345,
				size  =  500
			},
		},
		parts =  {
			Petales =  {
				{
					remote =  "Petales",
					off =  0,
					size =  72
				},
				{
					remote =  "Petales",
					off =  72,
					size =  72
				},
				{
					remote =  "Petales",
					off =  144,
					size =  72
				},
				{
					remote =  "Petales",
					off =  216,
					size =  72
				},
				{
					remote =  "Petales",
					off =  288,
					size =  72
				},
				{
					remote =  "Petales",
					off =  360,
					size =  72
				},
			},
			Spots =  {
				{
					remote =  "Spots",
					off =  0,
					size =  93
				}
			},
			Feuilles =  {
				{
					remote =  "Feuilles",
					off =  0,
					size =  216
				},
				{
					remote =  "Feuilles",
					off =  216,
					size =  162
				},
				{
					remote =  "Feuilles",
					off =  378,
					size =  216
				},
				{
					remote =  "Feuilles",
					off =  594,
					size =  162
				},
			},
			Tiges =  {
				{
					remote =  "Tige_et_support",
					off =  114,
					size =  52
				},
				{
					remote =  "Tige_et_support",
					off =  166,
					size =  52,
					invert =  true
				}
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
		name = "Plantoid_Grand",
		remotes =  {
			Petales =  {
				ip    =  "192.168.12.70",
				port  =  12345,
				size  =  288
			},
			Spots =  {
				ip    =  "192.168.12.71",
				port  =  12345,
				RGBW  =  true,
				size  =  93
			},
			Feuilles =  {
				ip    =  "192.168.12.72",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.12.73",
				port  =  12345,
				size  =  500
			},
		},
		parts =  {
		}
	},
	{
		name = "Plantoid_test",
		remotes =  {
			Spots =  {
				ip    =  "192.168.11.109",
				port  =  12345,
				size =  93,
				RGBW  =  true
			}
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
	{
		name = "Plantoid_test2",
		remotes =  {
			All =  {
				ip    =  "192.168.12.60",
				port  =  12345,
				size =  320,
				RGBW  =  false
			}
		},
		parts =  {
			Tiges =  {
				{
					remote =  "All",
					off =  0,
					size =  38
				},
				{
					remote =  "All",
					off =  204,
					size =  38,
					invert = true
				}
			},
			Petales =  {
				{
					remote =  "All",
					off =  48,
					size =  27
				},
				{
					remote =  "All",
					off =  75,
					size =  38
				},
				{
					remote =  "All",
					off =  113,
					size =  35
				},
				{
					remote =  "All",
					off =  148,
					size =  35
				}
			}
		}
	},
}
