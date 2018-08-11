return {
	{
		name = "Plantoid_Petit",
		remotes =  {
			Petales =  {
				ip    =  "192.168.10.148",
				port  =  12345,
				size  =  288
			},
			Spots =  {
				ip    =  "192.168.10.233",
				port  =  12345,
				RGBW  =  true,
				size  =  241
			},
			Feuilles =  {
				ip    =  "192.168.10.123",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.10.131",
				port  =  12345,
				size  =  500
			},
		},
		sensors = {
			{
				ip    =  "192.168.10.209",
				port  =  12345,
			},
		},
		parts =  {
			test =  {
				{
					remote =  "Tige_et_support",
					off =  0,
					size =  300
				},
			},
			test2 =  {
				{
					remote =  "Feuilles",
					off =  0,
					size =  300
				},
			},
			Spots =  {
				{
					remote =  "Spots",
					off =  0,
					size =  241
				},
			}
		}
	},
	{
		name =  "Plantoid_Moyen",
		remotes =  {
			Petales =  {
				ip    =  "192.168.10.160",
				port  =  12345,
				size  =  432
			},
			Spots =  {
				ip    =  "192.168.10.150",
				port  =  12345,
				RGBW  =  true,
				size  =  93
			},
			Feuilles =  {
				ip    =  "192.168.10.157",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.10.124",
				port  =  12345,
				size  =  500
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
				ip    =  "192.168.10.103",
				port  =  12345,
				size  =  288
			},
			Spots =  {
				ip    =  "192.168.10.242",
				port  =  12345,
				RGBW  =  true,
				size  =  93
			},
			Feuilles =  {
				ip    =  "192.168.10.172",
				port  =  12345,
				size  =  756
			},
			Tige_et_support =  {
				ip    =  "192.168.10.234",
				port  =  12345,
				size  =  500
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
		parts =  {}
	},
	{
		name = "Plantoid_test",
		remotes =  {
			Spots =  {
				ip    =  "192.168.12.109",
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
		sensors = {},
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
