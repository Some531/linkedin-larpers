import Foundation
import CoreLocation

/// Bundled demo data. Stands in for the versioned, human-verified template
/// bank served by the backend (docs/architecture.md §4) — content is written
/// by people, retrieved by the app, never generated on device.
///
/// Scenario: storm surge approaching Tacloban City (the Haiyan geography,
/// deliberately — see docs/research/philippines.md §2).
enum FixtureStore {

    /// Tacloban City centre — map fallback when location permission is denied.
    static let fallbackCenter = CLLocationCoordinate2D(latitude: 11.2433, longitude: 125.0039)

    static let alerts: [HazardAlert] = [
        HazardAlert(
            id: "alert-001",
            token: "7Kq2",
            hazard: .stormSurge,
            severity: .danger,
            phase: .happeningNow,
            issuedAt: Date().addingTimeInterval(-25 * 60),
            areaName: "Brgy San Jose, Tacloban City",
            headline: LocalizedText([
                .english: "Sea water is rising in Brgy San Jose. Go to high ground NOW.",
                .tagalog: "Tumataas ang tubig-dagat sa Brgy San Jose. Umakyat sa mataas na lugar NGAYON.",
                .cebuano: "Nagsaka ang tubig sa dagat sa Brgy San Jose. Adto sa habog nga lugar KARON.",
                .waray: "Nasaka an tubig han dagat ha Brgy San Jose. Kadto ha hitaas nga lugar YANA.",
            ]),
            actions: [
                LocalizedText([
                    .english: "Go to high ground on foot now. Do not wait for the water to reach you.",
                    .tagalog: "Maglakad papunta sa mataas na lugar ngayon. Huwag hintayin ang tubig.",
                    .waray: "Lakat ngadto ha hitaas nga lugar yana. Ayaw hulata an tubig.",
                ]),
                LocalizedText([
                    .english: "Nearest safe place: Brgy San Jose Elementary School (2nd floor and above).",
                    .tagalog: "Pinakamalapit na ligtas na lugar: Brgy San Jose Elementary School (2nd floor pataas).",
                    .waray: "Pinakaharani nga talwas nga lugar: Brgy San Jose Elementary School (2nd floor pataas).",
                ]),
                LocalizedText([
                    .english: "Do not go to the shore to watch the sea. The water comes faster than you can run.",
                    .tagalog: "Huwag pumunta sa dalampasigan para manood. Mas mabilis ang tubig kaysa sa takbo mo.",
                    .waray: "Ayaw kadto ha baybayon para magkita. Mas madagmit an tubig kaysa ha imo dalagan.",
                ]),
            ],
            details: LocalizedText([
                .english: "PAGASA expects sea water 3 to 4 metres above normal along the coast of San Jose district until 6 PM. This is like the water that came with Typhoon Yolanda. Houses near the shore will be flooded above head height.",
                .tagalog: "Inaasahan ng PAGASA na tataas ang tubig-dagat ng 3 hanggang 4 na metro sa baybayin ng San Jose hanggang 6 PM. Katulad ito ng tubig noong Bagyong Yolanda. Lulubog ang mga bahay malapit sa dagat nang lampas sa ulo.",
                .waray: "Ginlalauman han PAGASA nga masaka an tubig han dagat hin 3 tubtob 4 ka metro ha baybayon han San Jose tubtob alas 6 han kulop. Sugad ini han tubig han Bagyo nga Yolanda. Malunod an mga balay nga harani ha dagat hin labaw ha ulo.",
            ]),
            issuedBy: "PAGASA, via Tacloban City DRRMO"
        ),
        HazardAlert(
            id: "alert-002",
            token: "9Xw4",
            hazard: .flashFlood,
            severity: .warning,
            phase: .expectedSoon,
            issuedAt: Date().addingTimeInterval(-2 * 3600),
            areaName: "Palo and Tanauan, Leyte",
            headline: LocalizedText([
                .english: "Heavy rain may flood low areas of Palo and Tanauan tonight.",
                .tagalog: "Maaaring bumaha sa mababang lugar ng Palo at Tanauan ngayong gabi dahil sa malakas na ulan.",
                .waray: "Bangin magbaha ha hamubo nga mga lugar han Palo ngan Tanauan yana nga gab-i tungod han makusog nga uran.",
            ]),
            actions: [
                LocalizedText([
                    .english: "Move important things above knee height before dark.",
                    .tagalog: "Iakyat ang mahahalagang gamit nang lampas-tuhod bago dumilim.",
                    .waray: "Isaka an importante nga mga gamit labaw ha tuhod antes magsirom.",
                ]),
                LocalizedText([
                    .english: "Charge your phone and prepare a flashlight now.",
                    .tagalog: "I-charge ang cellphone at ihanda ang flashlight ngayon.",
                    .waray: "I-charge an imo cellphone ngan andama an flashlight yana.",
                ]),
            ],
            details: LocalizedText([
                .english: "PAGASA forecasts 100 to 200 mm of rain over Leyte in the next 12 hours. Rivers may overflow after midnight. Barangay officials will sound three long bell rings if you must evacuate.",
                .tagalog: "Inaasahan ng PAGASA ang 100 hanggang 200 mm ng ulan sa Leyte sa susunod na 12 oras. Maaaring umapaw ang mga ilog pagkalipas ng hatinggabi. Tatlong mahabang tunog ng kampana ang hudyat ng barangay kung kailangang lumikas.",
            ]),
            issuedBy: "PAGASA, via Leyte PDRRMO"
        ),
        HazardAlert(
            id: "alert-003",
            token: "2Fb8",
            hazard: .earthquake,
            severity: .advisory,
            phase: .prepare,
            issuedAt: Date().addingTimeInterval(-26 * 3600),
            areaName: "Eastern Visayas",
            headline: LocalizedText([
                .english: "Small aftershocks may continue this week. No tsunami is expected.",
                .tagalog: "Maaaring magpatuloy ang maliliit na aftershock ngayong linggo. Walang inaasahang tsunami.",
                .waray: "Bangin magpadayon an gudti nga mga aftershock yana nga semana. Waray ginlalauman nga tsunami.",
            ]),
            actions: [
                LocalizedText([
                    .english: "If shaking starts: drop to the floor, cover your head, hold on to something strong.",
                    .tagalog: "Kapag lumindol: dumapa, takpan ang ulo, kumapit sa matibay.",
                    .waray: "Kon maglinog: humapa, taboni an ulo, kapti an marig-on.",
                ]),
            ],
            details: LocalizedText([
                .english: "PHIVOLCS recorded a magnitude 4.8 earthquake near Leyte yesterday. Aftershocks are normal and usually weaker than the first earthquake. Check your house for cracks in posts and walls.",
                .tagalog: "Nakapagtala ang PHIVOLCS ng magnitude 4.8 na lindol malapit sa Leyte kahapon. Normal ang aftershock at kadalasang mas mahina. Tingnan kung may bitak ang mga poste at pader ng bahay.",
            ]),
            issuedBy: "PHIVOLCS"
        ),
    ]

    static let glossary: [GlossaryTerm] = [
        GlossaryTerm(
            id: "g-storm-surge",
            hazard: .stormSurge,
            term: HazardType.stormSurge.name,
            meaning: LocalizedText([
                .english: "Sea water pushed onto the land by a typhoon's wind. It rises fast, like a flood from the sea, and can be higher than a house. It is NOT the same as a tsunami, but it is just as dangerous.",
                .tagalog: "Tubig-dagat na itinutulak ng hangin ng bagyo papunta sa lupa. Mabilis itong tumataas, parang baha mula sa dagat, at maaaring mas mataas pa sa bahay. HINDI ito tsunami, pero kasing-delikado nito.",
                .waray: "Tubig han dagat nga ginduduso han hangin han bagyo ngadto ha tuna. Madagmit ini nga nasaka, sugad hin baha tikang ha dagat, ngan bangin mas hitaas pa ha balay. DIRI ini tsunami, pero pareho ka-peligro.",
            ]),
            action: LocalizedText([
                .english: "If a storm surge warning is given for your area, go to high ground or a strong tall building BEFORE the typhoon arrives. Do not stay to guard your house.",
                .tagalog: "Kapag may babala ng daluyong sa inyong lugar, pumunta sa mataas na lugar o matibay na mataas na gusali BAGO dumating ang bagyo. Huwag magbantay ng bahay.",
                .waray: "Kon may pahamangno hin dako nga balod ha iyo lugar, kadto ha hitaas nga lugar o marig-on nga hitaas nga bilding ANTES umabot an bagyo. Ayaw pagbantay han balay.",
            ])
        ),
        GlossaryTerm(
            id: "g-signal",
            hazard: .typhoon,
            term: LocalizedText([
                .english: "Typhoon Signal No. 1–5",
                .tagalog: "Signal No. 1–5",
                .waray: "Signal No. 1–5",
            ]),
            meaning: LocalizedText([
                .english: "PAGASA's wind warning scale. Signal 1 is the weakest, Signal 5 the strongest. The signal is about WIND — flooding and storm surge can be deadly even at low signal numbers.",
                .tagalog: "Sukatan ng PAGASA para sa lakas ng hangin. Signal 1 ang pinakamahina, Signal 5 ang pinakamalakas. Tungkol sa HANGIN ang signal — ang baha at daluyong ay maaaring nakamamatay kahit mababa ang signal.",
            ]),
            action: LocalizedText([
                .english: "At Signal 3 or higher, stay inside a strong building away from windows. Follow evacuation orders at any signal number.",
                .tagalog: "Sa Signal 3 pataas, manatili sa matibay na gusali malayo sa bintana. Sundin ang utos na lumikas anuman ang signal.",
            ])
        ),
        GlossaryTerm(
            id: "g-tsunami",
            hazard: .tsunami,
            term: HazardType.tsunami.name,
            meaning: LocalizedText([
                .english: "A series of huge sea waves caused by an earthquake under the sea. The first wave is often not the biggest. The sea may pull back far from the shore first — that is a warning sign, not a curiosity.",
                .tagalog: "Sunud-sunod na malalaking alon mula sa lindol sa ilalim ng dagat. Kadalasan, hindi ang unang alon ang pinakamalaki. Maaaring umatras muna ang dagat — babala iyon, hindi panoorin.",
            ]),
            action: LocalizedText([
                .english: "If the ground shakes hard near the coast, do not wait for a warning. Go inland or to high ground immediately and stay there for several hours.",
                .tagalog: "Kapag lumindol nang malakas malapit sa dagat, huwag maghintay ng babala. Pumunta agad sa malayo sa dagat o sa mataas na lugar, at manatili roon nang ilang oras.",
            ])
        ),
        GlossaryTerm(
            id: "g-landslide",
            hazard: .landslide,
            term: HazardType.landslide.name,
            meaning: LocalizedText([
                .english: "Soil and rocks sliding down a slope, usually after long heavy rain or an earthquake. Cracks in the ground, tilting trees, and muddy water from springs are warning signs.",
                .tagalog: "Pagbagsak ng lupa at bato mula sa gulod, kadalasan pagkatapos ng mahabang malakas na ulan o lindol. Mga bitak sa lupa, tumatagilid na puno, at maputik na tubig sa bukal ay mga babala.",
            ]),
            action: LocalizedText([
                .english: "If you see these signs, move your family away from the slope and tell your barangay officials immediately.",
                .tagalog: "Kapag nakita ang mga senyales na ito, ilayo ang pamilya sa gulod at ipagbigay-alam agad sa barangay.",
            ])
        ),
    ]

    static let checklist: [ChecklistItem] = [
        ChecklistItem(id: "c-water", text: LocalizedText([
            .english: "Store drinking water — 4 litres per person per day, for 3 days.",
            .tagalog: "Mag-ipon ng inuming tubig — 4 na litro bawat tao bawat araw, para sa 3 araw.",
        ])),
        ChecklistItem(id: "c-docs", text: LocalizedText([
            .english: "Put IDs and important papers in a sealed plastic bag.",
            .tagalog: "Ilagay ang mga ID at mahahalagang papeles sa selyadong plastic bag.",
        ])),
        ChecklistItem(id: "c-meds", text: LocalizedText([
            .english: "Pack medicines for one week, especially for elderly family members.",
            .tagalog: "Maghanda ng gamot para sa isang linggo, lalo na para sa matatanda.",
        ])),
        ChecklistItem(id: "c-radio", text: LocalizedText([
            .english: "Keep a battery radio and flashlight where you can find them in the dark.",
            .tagalog: "Ilagay ang de-bateryang radyo at flashlight kung saan makikita kahit madilim.",
        ])),
        ChecklistItem(id: "c-route", text: LocalizedText([
            .english: "Walk your evacuation route with the whole family once. Know where the evacuation centre is.",
            .tagalog: "Lakarin ang ruta ng paglikas kasama ang buong pamilya nang isang beses. Alamin kung nasaan ang evacuation center.",
        ])),
        ChecklistItem(id: "c-neighbours", text: LocalizedText([
            .english: "Agree with neighbours who will help elderly or disabled residents evacuate.",
            .tagalog: "Pag-usapan ng magkakapitbahay kung sino ang tutulong sa matatanda o may kapansanan kapag lumikas.",
        ])),
    ]

    /// Landmarks around the fixture area (San Jose district, Tacloban).
    /// Coordinates are approximate demo values, not survey data.
    static let landmarks: [Landmark] = [
        Landmark(id: "l-1", name: "Eastern Visayas Medical Center", kind: .hospital,
                 coordinate: CLLocationCoordinate2D(latitude: 11.2447, longitude: 124.9990)),
        Landmark(id: "l-2", name: "Brgy San Jose Elementary School (Evacuation Centre)", kind: .evacuationCenter,
                 coordinate: CLLocationCoordinate2D(latitude: 11.2286, longitude: 125.0210)),
        Landmark(id: "l-3", name: "Tacloban City Convention Center", kind: .evacuationCenter,
                 coordinate: CLLocationCoordinate2D(latitude: 11.2298, longitude: 125.0089)),
        Landmark(id: "l-4", name: "Brgy San Jose Barangay Hall", kind: .barangayHall,
                 coordinate: CLLocationCoordinate2D(latitude: 11.2273, longitude: 125.0245)),
    ]

    static func alert(forToken token: String) -> HazardAlert? {
        alerts.first { $0.token == token }
    }
}
