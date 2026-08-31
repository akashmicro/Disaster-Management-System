import html
import re

from fastapi import APIRouter, Form, Request

from database import execute
from main import templates

router = APIRouter()

TOPIC_GUIDANCE = {
    "fever": (
        "For fever: rest, drink safe fluids, check your temperature, and wear light clothing. "
        "Seek medical advice for a very high fever, fever in an infant, confusion, stiff neck, "
        "severe dehydration, or fever lasting more than a few days."
    ),
    "dengue": (
        "For possible dengue: use fluids and oral rehydration, rest, and seek testing or clinical advice. "
        "Avoid aspirin or ibuprofen unless a clinician says they are safe because bleeding risk can matter. "
        "Urgent care is needed for bleeding, severe belly pain, repeated vomiting, extreme weakness, "
        "breathing difficulty, or worsening symptoms when fever falls."
    ),
    "common cold": (
        "For common-cold symptoms: rest, drink fluids, use warm liquids or saline for comfort, "
        "and avoid antibiotics unless prescribed. Seek care for breathing difficulty, dehydration, "
        "or symptoms that are severe or not improving."
    ),
    "cough": (
        "For cough: drink fluids, avoid smoke, and use a humid environment if it helps. "
        "Get medical advice for blood in sputum, chest pain, breathing difficulty, a persistent cough, "
        "or cough with a high fever."
    ),
    "sore throat": (
        "For a sore throat: drink warm fluids, rest your voice, and try a salt-water gargle if appropriate. "
        "Seek care for trouble swallowing saliva, one-sided swelling, breathing difficulty, or persistent symptoms."
    ),
    "flu": (
        "For flu-like illness: rest, hydrate, limit close contact while feverish, and ask a clinician "
        "about testing or treatment when symptoms are severe or you are high risk. Seek urgent care for breathing difficulty or confusion."
    ),
    "asthma": (
        "For asthma symptoms: move away from triggers and follow your prescribed action plan or reliever inhaler instructions. "
        "Emergency help is needed if speaking is difficult, lips look blue, or breathing does not improve."
    ),
    "allergy": (
        "For mild allergy symptoms: avoid the suspected trigger and ask a pharmacist about suitable treatment. "
        "Sudden swelling of the lips or tongue, wheezing, faintness, or breathing difficulty is an emergency."
    ),
    "headache": (
        "For headache: rest in a quiet place, drink fluids, and note possible triggers such as poor sleep or missed meals. "
        "A sudden worst-ever headache, weakness, confusion, fever with stiff neck, or head injury needs urgent care."
    ),
    "migraine": (
        "For possible migraine: rest in a dark quiet room, hydrate, and record triggers and symptoms. "
        "A new severe headache, neurological symptoms, pregnancy-related severe headache, or repeated vomiting needs medical review."
    ),
    "stomach pain": (
        "For stomach pain: take fluids in small amounts, avoid foods that worsen it, and monitor changes. "
        "Severe or localized pain, a rigid abdomen, fainting, blood in stool or vomit, or pregnancy with pain needs urgent care."
    ),
    "vomiting": (
        "For vomiting: take frequent small sips of oral rehydration solution or safe fluids and restart light food gradually. "
        "Seek care for blood, severe pain, confusion, very little urine, or inability to keep fluids down."
    ),
    "diarrhea": (
        "For diarrhea: use oral rehydration solution, continue safe food as tolerated, and wash hands carefully. "
        "Seek care for blood, high fever, severe dehydration, severe pain, or diarrhea lasting longer than expected."
    ),
    "dehydration": (
        "For possible dehydration: use oral rehydration solution in small frequent sips and monitor urine output. "
        "Confusion, fainting, inability to drink, or very little urine requires urgent medical help."
    ),
    "skin rash": (
        "For a rash: avoid suspected irritants, do not scratch, and take a photo to track changes. "
        "A rapidly spreading rash, facial swelling, blistering, fever, or purple spots needs prompt medical assessment."
    ),
    "wound": (
        "For a minor wound: wash hands, rinse with clean running water, apply gentle pressure for bleeding, and cover it. "
        "Get care for deep or dirty wounds, animal bites, uncontrolled bleeding, spreading redness, pus, or fever."
    ),
    "burn": (
        "For a small burn: cool it under clean running water for about 20 minutes and cover it loosely. "
        "Do not apply ice, toothpaste, or butter. Emergency care is needed for large, deep, electrical, chemical, or facial burns."
    ),
    "diabetes": (
        "For diabetes concerns: follow your clinician's plan, monitor glucose if you have a meter, and do not change medicine doses alone. "
        "Confusion, fainting, very high or low glucose, vomiting, or deep breathing needs urgent care."
    ),
    "high blood pressure": (
        "For high blood pressure: rest before repeating a reading, record readings, reduce excess salt, and arrange clinical follow-up. "
        "Chest pain, severe headache, weakness, confusion, or breathing difficulty with a very high reading is urgent."
    ),
    "heart symptoms": (
        "For possible heart symptoms: stop exertion and seek emergency help for chest pressure or pain, sweating, nausea, faintness, "
        "pain spreading to the arm or jaw, or breathing difficulty. Do not wait for an online explanation."
    ),
    "sexual health": (
        "For sexual-health concerns: confidential clinical care is appropriate and common. Use condoms or other barrier protection, "
        "avoid self-prescribed antibiotics or sexual-performance medicines, and consider STI testing for discharge, sores, pain, "
        "burning, or a new exposure. Severe pain, heavy bleeding, or assault requires urgent care."
    ),
    "erectile or sexual function": (
        "For erectile or sexual-function concerns: stress, medicines, diabetes, circulation, and relationship factors can contribute. "
        "A clinician can assess this confidentially. Do not buy unverified pills online or combine performance medicines with nitrate drugs."
    ),
    "menstrual or pelvic pain": (
        "For menstrual or pelvic pain: rest, fluids, and a heat pack may help if safe for you. "
        "Seek care for severe or new pain, very heavy bleeding, fainting, fever, pregnancy possibility, or pain after sexual activity."
    ),
    "pregnancy": (
        "For pregnancy-related symptoms: contact a qualified maternity clinician before taking medicines or supplements. "
        "Urgent care is needed for heavy bleeding, severe abdominal pain, severe headache, vision changes, fever, or reduced fetal movement."
    ),
    "back or joint pain": (
        "For back or joint pain: keep gentle movement as tolerated, avoid heavy lifting, and use a comfortable position. "
        "Weakness, numbness around the groin, loss of bladder or bowel control, fever, major injury, or worsening pain needs urgent review."
    ),
    "anxiety or panic": (
        "For anxiety or panic: move to a safe place, slow your breathing, name things you can see and hear, and contact someone you trust. "
        "Chest pain, fainting, severe breathing difficulty, or thoughts of self-harm require emergency help."
    ),
    "depression": (
        "For low mood or depression: tell a trusted person, keep basic sleep and food routines, and arrange support from a mental-health professional. "
        "Any thoughts of self-harm or suicide are urgent: contact emergency services or a crisis service and stay with a trusted person."
    ),
    "heartbreak or relationship stress": (
        "For heartbreak or relationship stress: give yourself time, stay connected to trusted people, eat and sleep regularly, "
        "and limit contact that makes you unsafe. A counselor can help. If you may hurt yourself or someone else, seek emergency help now."
    ),
}

TOPIC_DETAILS = {
    "fever": {
        "details": "Fever is a temporary rise in body temperature, usually a sign that the immune system is responding to an infection or another condition.",
        "symptoms": ("raised temperature", "chills or sweating", "body aches", "tiredness"),
        "reasons": ("viral or bacterial infection", "dehydration or heat exposure", "inflammation or a medicine reaction"),
        "prevention": ("wash hands regularly", "drink safe water and keep hydrated", "avoid close contact when ill"),
        "medicine": "Paracetamol may help fever or body discomfort when it is safe for you and used exactly according to the packet or a clinician's advice. Avoid aspirin for children and do not combine products containing paracetamol.",
    },
    "dengue": {
        "details": "Dengue is a mosquito-borne viral infection. It can become serious, especially around the time the fever starts to improve.",
        "symptoms": ("high fever", "severe headache or pain behind the eyes", "muscle and joint pain", "nausea or rash"),
        "reasons": ("the dengue virus carried by an infected Aedes mosquito",),
        "prevention": ("remove standing water around the home", "use mosquito nets or repellent", "wear clothing that covers the skin"),
        "medicine": "There is no routine over-the-counter medicine that cures dengue. Paracetamol may be considered for fever only if safe; avoid aspirin or ibuprofen unless a clinician specifically advises them.",
    },
    "common cold": {
        "details": "The common cold is a usually mild infection of the nose and throat that generally improves with rest and supportive care.",
        "symptoms": ("runny or blocked nose", "sneezing", "sore throat", "mild cough"),
        "reasons": ("different respiratory viruses", "close contact with an infected person",),
        "prevention": ("wash hands and avoid touching the face", "cover coughs and sneezes", "avoid sharing personal items when ill"),
        "medicine": "Saline nasal spray, warm fluids, or a pharmacist-recommended symptom treatment may help. Antibiotics do not treat a common cold.",
    },
    "flu": {
        "details": "Flu is an infectious respiratory illness caused by influenza viruses and can be more serious for older adults, young children, pregnant people, and people with chronic conditions.",
        "symptoms": ("sudden fever or chills", "cough and sore throat", "body aches", "marked tiredness"),
        "reasons": ("influenza virus infection", "breathing in droplets from an infected person",),
        "prevention": ("consider seasonal vaccination where available", "wash hands and improve ventilation", "stay home while feverish"),
        "medicine": "A clinician may consider antiviral treatment early for people at higher risk. Do not start antibiotics without medical advice; use fever medicine only as directed and if safe.",
    },
    "cough": {
        "details": "A cough is a protective reflex that clears the airways. It may be short-lived or may need assessment if it persists.",
        "symptoms": ("dry or mucus-producing cough", "throat irritation", "wheeze or chest discomfort"),
        "reasons": ("a cold or flu", "asthma or allergy", "smoke, pollution, reflux, or another airway problem"),
        "prevention": ("avoid smoke and known triggers", "wash hands regularly", "keep indoor air well ventilated"),
        "medicine": "Use only an inhaler or cough medicine suitable for you after pharmacist or clinician advice. Cough medicines are not suitable for every age or condition.",
    },
    "diarrhea": {
        "details": "Diarrhea means frequent loose or watery stools. The main risk is loss of water and salts, which can cause dehydration.",
        "symptoms": ("loose or watery stools", "stomach cramps", "nausea", "thirst or reduced urination"),
        "reasons": ("viral or bacterial infection", "contaminated food or water", "food intolerance or medicine side effects"),
        "prevention": ("drink safe water", "wash hands before eating and after using the toilet", "cook and store food safely"),
        "medicine": "Oral rehydration solution is usually more important than anti-diarrheal medicine. Ask a pharmacist before using anti-diarrheals, especially for children, fever, or blood in stool.",
    },
    "dehydration": {
        "details": "Dehydration occurs when the body loses more fluid than it takes in. It can become dangerous if severe or untreated.",
        "symptoms": ("thirst and dry mouth", "dark or infrequent urine", "dizziness", "weakness or confusion"),
        "reasons": ("vomiting or diarrhea", "fever, heavy sweating, or heat", "not drinking enough fluids"),
        "prevention": ("drink regularly, especially in heat", "use oral rehydration solution during fluid loss", "treat vomiting or diarrhea promptly"),
        "medicine": "Use a correctly prepared oral rehydration solution. Severe dehydration may need urgent treatment at a healthcare facility; do not rely on sports drinks for severe fluid loss.",
    },
    "diabetes": {
        "details": "Diabetes is a condition in which blood glucose remains too high because the body does not make enough insulin or cannot use it effectively.",
        "symptoms": ("increased thirst or urination", "tiredness", "blurred vision", "slow-healing wounds"),
        "reasons": ("type 1 or type 2 diabetes", "family history and metabolic risk", "some medicines or other health conditions"),
        "prevention": ("keep scheduled health checks", "be physically active as appropriate", "follow a clinician's food and medicine plan"),
        "medicine": "Take diabetes medicine or insulin only as prescribed and do not change the dose yourself. Check glucose if you have a meter and ask a clinician about unusual readings.",
    },
    "high blood pressure": {
        "details": "High blood pressure means blood pushes against artery walls with persistently elevated force. It often has no obvious symptoms but can damage the heart, brain, and kidneys.",
        "symptoms": ("often no symptoms", "sometimes headache or dizziness", "chest pain or breathing difficulty when severe"),
        "reasons": ("family history and age", "high salt intake, inactivity, or excess weight", "kidney disease, medicines, or other conditions"),
        "prevention": ("check blood pressure regularly", "limit excess salt and avoid tobacco", "stay active and take prescribed treatment"),
        "medicine": "Blood-pressure medicine must be selected and adjusted by a clinician. Continue prescribed medicine and do not use someone else's tablets or stop treatment suddenly.",
    },
    "skin rash": {
        "details": "A rash is a visible change in the skin. Its meaning depends on its appearance, location, timing, and other symptoms.",
        "symptoms": ("redness or changed skin colour", "itching", "bumps, scaling, or blisters"),
        "reasons": ("allergy or irritation", "infection", "heat, medicines, or an inflammatory skin condition"),
        "prevention": ("avoid known irritants", "keep skin clean and dry", "do not share towels or personal items during possible infection"),
        "medicine": "A pharmacist may suggest a suitable moisturizer or anti-itch treatment after seeing the rash. Do not use steroid, antibiotic, or combination creams without advice.",
    },
}


def topic_sections(topic):
    info = {
        "details": f"{topic.title()} describes a health concern that can have different causes and levels of severity. An online suggestion cannot confirm the diagnosis.",
        "symptoms": ("the symptoms you described", "symptoms may change or become more severe"),
        "reasons": ("infection, inflammation, an underlying condition, or environmental factors", "medicines, allergies, or lifestyle factors"),
        "prevention": ("avoid known triggers and maintain good hygiene", "drink safe fluids and follow a healthy routine", "seek clinical advice when symptoms persist or worsen"),
        "medicine": "Medicine depends on the cause. Do not self-start antibiotics, steroids, sleeping tablets, or prescription medicine; ask a qualified clinician or pharmacist.",
    }
    info.update(TOPIC_DETAILS.get(topic, {}))

    def points(items):
        return "".join(f"<li>{html.escape(item)}</li>" for item in items)

    return (
        f"<section class='health-topic'><h2>{html.escape(topic.title())}: details and explanation</h2>"
        f"<p>{html.escape(info['details'])}</p>"
        f"<h3>Symptoms</h3><ul>{points(info['symptoms'])}</ul>"
        f"<h3>Possible reasons</h3><ul>{points(info['reasons'])}</ul>"
        f"<h3>Prevention</h3><ul>{points(info['prevention'])}</ul>"
        f"<h3>Medicine information</h3><p>{html.escape(info['medicine'])}</p>"
        f"<p><strong>What to do now:</strong> {html.escape(TOPIC_GUIDANCE[topic])}</p></section>"
    )


def detect_topics(lower):
    matches = []
    keyword_groups = {
        "fever": ("fever", "temperature", "জ্বর"),
        "dengue": ("dengue", "ডেঙ্গু"),
        "common cold": ("common cold", "cold", "সর্দি"),
        "cough": ("cough", "কাশি"),
        "sore throat": ("sore throat", "গলা ব্যথা"),
        "flu": ("flu", "influenza", "ফ্লু"),
        "asthma": ("asthma", "হাঁপানি"),
        "allergy": ("allergy", "allergic", "অ্যালার্জি"),
        "headache": ("headache", "মাথা ব্যথা"),
        "migraine": ("migraine", "মাইগ্রেন"),
        "stomach pain": ("stomach pain", "abdominal pain", "পেট ব্যথা"),
        "vomiting": ("vomit", "vomiting", "বমি"),
        "diarrhea": ("diarrhea", "diarrhoea", "ডায়রিয়া"),
        "dehydration": ("dehydration", "dehydrated"),
        "skin rash": ("rash", "skin problem", "চুলকানি"),
        "wound": ("cut", "wound", "injury", "ক্ষত"),
        "burn": ("burn", "পোড়া"),
        "diabetes": ("diabetes", "diabetic", "ডায়াবেটিস"),
        "high blood pressure": ("high blood pressure", "hypertension", "pressure বেশি"),
        "heart symptoms": ("heart problem", "heart pain", "palpitation", "বুকে ব্যথা"),
        "sexual health": ("sex", "sexual", "sti", "std", "sexual problem", "যৌন"),
        "erectile or sexual function": ("erectile", "erection", "impotence"),
        "menstrual or pelvic pain": ("period pain", "menstrual", "pelvic", "মাসিক"),
        "pregnancy": ("pregnant", "pregnancy", "গর্ভবতী"),
        "back or joint pain": ("back pain", "joint pain", "জয়েন্ট", "কোমর ব্যথা"),
        "anxiety or panic": ("anxiety", "panic", "উদ্বেগ"),
        "depression": ("depression", "depressed", "বিষণ্ণ"),
        "heartbreak or relationship stress": ("heartbreak", "broken heart", "breakup", "relationship problem"),
    }
    for topic, keywords in keyword_groups.items():
        if any(keyword in lower for keyword in keywords):
            matches.append(topic)
    return matches


@router.get("/health-ai")
def health_page(request: Request):
    return templates.TemplateResponse("health.html", {"request": request, "answer": None})


@router.post("/health-ai")
def health_answer(request: Request, symptoms: str = Form(...)):
    text = re.sub(r"\s+", " ", symptoms.strip())
    lower = text.lower()
    emergency_terms = (
        "breathing difficulty", "shortness of breath", "chest pain", "unconscious",
        "seizure", "blue lips", "severe bleeding", "paralysis", "fainting",
        "suicidal", "suicide", "self harm", "kill myself", "heavy bleeding",
    )
    emergency = any(term in lower for term in emergency_terms)
    topics = detect_topics(lower)
    if emergency:
        answer = (
            "This may be an emergency because you mentioned a serious warning sign. "
            "Call your local emergency service now, do not drive yourself if severely unwell, "
            "and ask someone to stay with you. "
        )
    else:
        subject = ", ".join(topics) if topics else "the symptoms described"
        if topics:
            answer = "".join(topic_sections(topic) for topic in topics)
        else:
            answer = (
                "<section class='health-topic'><h2>Symptoms described: details and explanation</h2>"
                "<p>The symptoms provided are not specific enough to identify one disease. A clinician may need to examine you and ask additional questions.</p>"
                "<h3>Symptoms</h3><ul><li>Track when symptoms started and whether they are worsening</li><li>Note fever, pain, breathing changes, vomiting, or other new symptoms</li></ul>"
                "<h3>Possible reasons</h3><ul><li>Infections, allergies, dehydration, stress, medicines, or other conditions can cause similar symptoms</li></ul>"
                "<h3>Prevention</h3><ul><li>Wash hands, drink safe fluids, rest, and avoid known triggers</li><li>Seek medical advice if symptoms are severe, worsening, or persistent</li></ul>"
                "<h3>Medicine information</h3><p>Medicine depends on the cause and your age, allergies, pregnancy status, and other conditions. Do not self-start antibiotics or prescription medicine; ask a qualified clinician or pharmacist.</p>"
                "<p><strong>What to do now:</strong> Rest, drink safe fluids, monitor changes, and avoid taking antibiotics or prescription medicine without a clinician.</p></section>"
            )
        if not topics:
            answer += (
                "Rest, drink safe fluids, monitor changes, and avoid taking antibiotics or prescription "
                "medicine without a clinician. Contact a doctor if symptoms are severe, worsening, or persistent. "
            )
    answer += (
        "This information is educational and cannot diagnose your condition. "
        "Use the Emergency Help page or contact a healthcare professional for personal advice."
    )
    if request.session.get("user_id"):
        execute("INSERT INTO health_ai_chats (user_id,question,answer) VALUES (%s,%s,%s)",
                (request.session["user_id"], symptoms.strip(), answer))
    return templates.TemplateResponse("health.html", {"request": request, "answer": answer})
