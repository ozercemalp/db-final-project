import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../AuthContext';

const CreatePost = () => {
  const [subforums, setSubforums] = useState([]);
  const [selectedSubforum, setSelectedSubforum] = useState('');
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!user) navigate('/login');
    const fetchSubforums = async () => {
        try {
            const res = await axios.get('/api/subforums');
            setSubforums(res.data);
            if (res.data.length > 0) setSelectedSubforum(res.data[0].SUBFORUM_ID);
        } catch (err) {
            console.error(err);
        }
    };
    fetchSubforums();
  }, [user, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('/api/posts', {
        user_id: user.user_id,
        subforum_id: selectedSubforum,
        title,
        content
      });
      navigate('/');
    } catch (err) {
      alert("Failed to create post: " + (err.response?.data?.error || err.message));
    }
  };

  return (
    <div className="container mx-auto py-8 flex justify-center">
      <div className="w-full md:w-2/3 bg-white p-6 rounded shadow border border-gray-300">
        <h1 className="text-xl font-bold mb-4 border-b pb-2">Create a Post</h1>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
              <label className="block font-bold mb-1">Choose a community</label>
              <select
                className="w-full border p-2 rounded"
                value={selectedSubforum}
                onChange={(e) => setSelectedSubforum(e.target.value)}
              >
                  {subforums.map(sub => (
                      <option key={sub.SUBFORUM_ID} value={sub.SUBFORUM_ID}>r/{sub.NAME}</option>
                  ))}
              </select>
          </div>
          <div className="mb-4">
             <input
               type="text"
               placeholder="Title"
               className="w-full border p-2 rounded font-bold"
               value={title}
               onChange={(e) => setTitle(e.target.value)}
               maxLength={300}
             />
          </div>
          <div className="mb-4">
             <textarea
               placeholder="Text (optional)"
               className="w-full border p-2 rounded h-40"
               value={content}
               onChange={(e) => setContent(e.target.value)}
             />
          </div>
          <div className="flex justify-end">
              <button
                type="submit"
                className="bg-blue-500 text-white font-bold py-2 px-6 rounded-full hover:bg-blue-600"
              >
                  Post
              </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CreatePost;
