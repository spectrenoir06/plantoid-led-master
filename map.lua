local map =  {
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
		name =  "Plantoid_Moyen",
		remotes =  {
			Petales =  {
				ip    =  "192.168.12.60",
				port  =  12345,
				size  =  288
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
					off =  278,
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
	}
}

return map
