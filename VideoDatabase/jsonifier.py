import json
"""
"en": [
        ("UCLXo7UDZvByw2ixzpQCufnA", "Vox"),
        ("UCHnyfMqiRRG1u-2MsSQLbXA", "Veritasium"),
        ("UCsXVk37bltHxD1rDPwtNM8Q", "Kurzgesagt – In a Nutshell"),
        ("UCsooa4yRKGN_zEE8iknghZA", "TED-Ed"),
        ("UCGYYNGmyhZ_kwBF_lqqXdAQ", "Tifo Football"),
        ("UCBa659QWEk1AI4Tg--mrJ2A", "Tom Scott"),
        ("UCV0qA-eDDICsRR9rPcnG7tw", "Joma Tech"),
        ("UCBIt1VN5j37PVM8LLSuTTlw", "Improvement Pill"),
        ("UCkvK_5omS-42Ovgah8KRKtg", "jeffreestar"),
        ("UCbAwSkqJ1W_Eg7wr3cp5BUA", "Sofiya Nygaard"),
        ("UCmGSJVG3mCRXVOP4yZrU1Dw", "Johnny Harris"),
        ("UC9_p50tH3WmMslWRWKnM7dQ", "Adam Ragusea"),
        ("UCJHA_jMfCvEnv-3kRjTCQXw", "Babish Culinary Universe"),
        ("UCpHvDA_ladtos5LKzl8TzkA", "Tech Gear Talk"),
        ("UCqVEHtQoXHmUCfJ-9smpTSg", "Answer in Progress"),
        ("UCsEukrAd64fqA7FjwkmZ_Dw", "GQ"),
        ("UCRXiA3h1no_PFkb1JCP0yMA", "Vogue"),
        ("UC0k238zFx-Z8xFH0sxCrPJg", "Architectural Digest"),
        ("UCzH5n3Ih5kgQoiDAQt2FwLw", "Pro Home Cooks"),
        ("UCPRUgAl_MV9PajsrG_BmT9w", "BuzzFeed Celeb"),
        ("UCftwRNsjfRo08xYE31tkiyw", "WIRED"),
    ],
    "de": [
        ("UCwRH985XgMYXQ6NxXDo8npw", "Dinge Erklärt – Kurzgesagt"),
        ("UCHpnIL-1QIUyVhdGVJ6rW3A", "24h Deutsch"),
        ("UCA3mpqm67CpJ13YfA8qAnow", "Terra X History"),
        ("UCZHpIFMfoJJ_1QxNGLJTzyA", "MrWissen2Go"),
        ("UCDw0K7K658-ztRuCn2mn0Kw", "Frontal"),
        ("UCTPAHk1b-h-WGQn9cfGlw2Q", "NDR Doku"),
        ("UCC9h3H-sGrvqd2otknZntsQ", "freekickerz"),
        ("UCTXeJ33DzXI2veQpKfrvaYw", "Julien Bam"),
        # ("UC1XrG1M_hw8103zO2x-oivg", "Galileo"),
        ("UC9YTp5M6yYgSd6t0SeL2GQw", "HandOfBlood"),
        # ("UCGcheBSVngQt09ubb0BZyJw", "MySpass.com"),
    ],
    "fr": [
        ("UCWeg2Pkate69NFdBeuRFTAw", "SQUEEZIE"),
        ("UCpWaR3gNAQGsX48cIlQC0qw", "Tibo InShape"),
        ("UCgvqvBoSHB1ctlyyhoHrGwQ", "Amixem"),
        ("UCDPK_MTu3uTUFJXRVcTJcEw", "Mcfly et Carlito"),
        ("UCJruTcTs7Gn2Tk7YC-ENeHQ", "Golden Moustache"),
        ("UCH0XvUpYcxn4V0iZGnZXMnQ", "Lama Faché"),
    ],
    "es": [
        ("UCK1i2UviaXLUNrZlAFpw_jA", "El Reino Infantil"),
        ("UCXazgXDIYyWH-yXLAkcrFxw", "elrubiusOMG"),
        ("UCqJ5zFEED1hWs0KNQCQuYdQ", "Mikecrack"),
        ("UCoGDh1Xa3kUCpok24JN5DKA", "enchufetv"),
        ("UCam8T03EOFBsNdR0thrFHdQ", "VEGETTA777"),
        ("UCYiGq8XF7YQD00x7wAd62Zg", "JuegaGerman"),
    ],
"""
channel_dict = {
    "it": [
        ("UCTQLIHHx6tXZYRBwilRzCnw", "Psicologia - Luca Mazzucchelli"),
        ("UCfZFwPGOpbWk0z0Fk7tU6yA", "MikeShowSha"),
        ("UCHZl_sLl4kGZSkrPBrWb_aQ", "Anima"),
        ("UCYZ3uwiIy1LrwrAywLeQSlQ", "theShow"),
        # ("UCfGk2x9k0vE14OoMlifGLCg", "Me contro Te"),
        ("UCD-aXv7CMezGSTfxmKAD6Ag", "iPantellas"),
    ],
    "pt": [
        ("UC9_p1FGLHErrNsV2AVbKVcg", "Hugo Lemos"),
        ("UCP6u9OBUd4M6U4yzSuv4UNw", "Klasszik"),
        ("UC3l2Zful_g75Ue4SxDvrnlw", "SEA3P0"),
        ("UCV306eHqgo0LvBf3Mh36AHg", "Felipe Neto"),
        ("UCKHhA5hN2UohhFDfNXB_cvQ", "Manual do Mundo"),
        ("UCddYq41_tZ1FnLlguLT6-Ow", "Parafernalha"),
        ("UCuxfOdbKQy0tgGXcm9sjHiw", "Coisa de Nerd"),
        ("UCKEM87jzVqdIfAdTr0xNBfA", "Pastor Antônio Júnior"),
        ("UClO_ni5PslPD9LsfZiyfcyA", "MIRACULOUS - As Aventuras de Ladybug"),
        ("UCbVwJCxsVbmaP1PFmbGQDeQ", "MK MUSIC"),
        ("UCbt4SegZBQLeXMTMvnrfZtw", "Gato Galactico | GALÁXIA"),
        ("UC7wseMScXyaEP7ubWutNZmQ", "D4rkFrame"),
        ("UCSHSIx0CttXzzuT3YLVZC7Q", "wuant"),
        ("UCSmFxzDZh8M2oKlRslNtdWw", "Pi"),
    ],
    "ru": [
        ("UCU_yU4xGT9hrVFo6euH8LLw", "SlivkiShow"),
        ("UCXTMoE1XgvxN4iCt5-gZzCw", "Познаватель"),
        ("UCyJrhZm9KXrzRub3-wD2zWg", "TheBrianMaps"),
        ("UCt7sv-NKh44rHAEb-qCCxvA", "Wylsacom"),
        ("UCuZeiI5pdpgqDojXZujoYgg", "Поззи"),
    ],
    "ja": [
        ("UCZf__ehlCEBPop-_sldpBUQ", "HikakinTV"),
        ("UCgMPP6RRjktV7krOfyUewqw", "はじめしゃちょー（hajime）"),
        ("UCibEhpu5HP45-w7Bq1ZIulw", "Fischer's-フィッシャーズ-"),
        ("UCutJqz56653xV2wwSvut_hQ", "東海オンエア"),
        ("UC1oPBUWifc0QOOY8DEKhLuQ", "avex"),
        ("UCX1xppLvuj03ubLio8jslyA", "HikakinGames"),
    ],
    "ko": [
        ("UC5BMQOsAB8hKUyHu9KI6yig", "KBS WORLD TV"),
        ("UCPde4guD9yFBRzkxk2PatoA", "ALL THE K-POP"),
        ("UCtCiO5t2voB14CmZKTkIzPQ", "딩고 뮤직 / dingo music"),
        ("UCmLiSrat4HW2k07ahKEJo4w", "CreamHeroes"),
        ("UCkinYTS9IHqOEwR1Sze2JTw", "SBS 뉴스"),
        ("UCF4Wxdo3inmxP-Y59wXDsFw", "MBCNEWS"),
        ("UCsJ6RuBiTVWRX156FVbeaGg", "슈카월드"),
        ("UChQ-VMvdGrYZxviQVMTJOHg", "Dotty"),
    ],
    "sv": [
        ("UCYf_7EOhgCYvfjUjarF1FUA", "KaptenRiley"),
    ],
    "pl": [
        ("UCzuvRWjh7k1SZm1RvqvIx4w", "Krzysztof Gonciarz"),
    ]
}

print(channel_dict)

# convert every channel_id, channel_name pair into a json object
# and add it to the list of channels
channels = {}
for language, channel_list in channel_dict.items():
    temp = []

    for element in channel_list:
        if len(element) == 2:
            channel_id, channel_name = element
            temp.append(
                {
                    "id": channel_id,
                    "name": channel_name,
                    "language": language,
                }
            )
    channels[language] = temp

json_ = json.dumps(channels, indent=4)

# put the json object into a file
with open("channels.json", "w") as f:
    f.write(json_)

channel_dict = json.load(open("channels.json", "r"))
print(channel_dict)

