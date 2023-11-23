const express = require('express');
const app = express();
const cors = require('cors');
const fs = require('fs');

const port = 3001;
let i =0;

app.use(express.json());
app.use(cors());

let data = [];
const dataFilePath = 'data.json';

function saveDataToFile() {
    fs.writeFileSync(dataFilePath, JSON.stringify(data, null, 2), 'utf8');
}

try {
    const jsonData = fs.readFileSync(dataFilePath, 'utf8');
    data = JSON.parse(jsonData);
} catch (error) {
    console.error('Erreur de lecture du fichier JSON:', error.message);
}

app.get('/', (req, res) => {
    res.send('Bienvenue sur votre backend !');
});

// Liste tous les éléments
app.get('/elements', (req, res) => {
    res.json(data);
});

// Ajoute un élément
app.post('/elements', (req, res) => {
    i++
    console.log('Requête POST reçue :', req.body);
    const newItem = {
        ...req.body,
        id: i,
    };
    data.push(newItem);
    saveDataToFile();
    res.json(newItem);
});

// Modifie un élément
app.put('/elements/:id', (req, res) => {
    const itemId = parseInt(req.params.id, 10);
    const updatedItem = req.body;
    // Recherche et met à jour l'élément
    const index = data.findIndex(item => item.id === itemId);
    
    if (index !== -1) {
        data[index] = { ...data[index], ...updatedItem };
        
        saveDataToFile();
        res.json(data[index]);
    } else {
        res.status(404).send('Élément non trouvé');
    }
});

// Supprime un élément
app.delete('/elements/:id', (req, res) => {
    const itemId = parseInt(req.params.id);
    console.log(itemId)
    // Filtrer les éléments sauf celui à supprimer
    data = data.filter(item => item.id !== itemId);
    saveDataToFile();
    res.send('Élément supprimé avec succès');
});

app.listen(port, () => {
    console.log(`Serveur en cours d'exécution sur http://localhost:${port}`);
});